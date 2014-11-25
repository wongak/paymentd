package paypal_rest

import (
	"database/sql"
	"net/http"
	"time"

	paymentService "github.com/fritzpay/paymentd/pkg/service/payment"

	"github.com/fritzpay/paymentd/pkg/paymentd/payment"
	"gopkg.in/inconshreveable/log15.v2"
)

func (d *Driver) CancelHandler() http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		log := d.log.New(log15.Ctx{"method": "CancelHandler"})
		paymentIDStr := r.URL.Query().Get(paymentIDParam)
		if paymentIDStr == "" {
			log.Info("request without payment ID")
			d.NotFoundHandler(nil).ServeHTTP(w, r)
			return
		}
		nonce := r.URL.Query().Get(nonceParam)
		if nonce == "" {
			log.Info("request without nonce")
			d.NotFoundHandler(nil).ServeHTTP(w, r)
		}
		paymentID, err := payment.ParsePaymentIDStr(paymentIDStr)
		if err != nil {
			log.Warn("error parsing payment ID", log15.Ctx{
				"err":          err,
				"paymentIDStr": paymentIDStr,
			})
			d.BadRequestHandler().ServeHTTP(w, r)
			return
		}
		paymentID = d.paymentService.DecodedPaymentID(paymentID)

		var tx *sql.Tx
		var commit bool
		defer func() {
			if tx != nil && !commit {
				err = tx.Rollback()
				if err != nil {
					log.Crit("error on rollback", log15.Ctx{"err": err})
				}
			}
		}()
		tx, err = d.ctx.PaymentDB().Begin()
		if err != nil {
			commit = true
			log.Crit("error on begin tx", log15.Ctx{"err": err})
			d.InternalErrorHandler(nil).ServeHTTP(w, r)
			return
		}

		_, err = TransactionByPaymentIDAndNonceTx(tx, paymentID, nonce)
		if err != nil {
			if err == ErrTransactionNotFound {
				log.Info("paypal transaction not found")
				d.NotFoundHandler(nil).ServeHTTP(w, r)
				return
			}
			log.Error("error retrieving paypal transaction")
			d.InternalErrorHandler(nil).ServeHTTP(w, r)
			return
		}
		p, err := payment.PaymentByIDTx(tx, paymentID)
		if err != nil {
			if err == payment.ErrPaymentNotFound {
				log.Info("payment not found", log15.Ctx{"err": err})
				d.NotFoundHandler(nil).ServeHTTP(w, r)
				return
			}
			log.Error("error retrieving payment", log15.Ctx{"err": err})
			d.InternalErrorHandler(nil).ServeHTTP(w, r)
			return
		}

		var paymentTx *payment.PaymentTransaction
		var commitIntent paymentService.CommitIntentFunc
		if p.Status != payment.PaymentStatusCancelled {
			if Debug {
				log.Debug("intent cancel")
			}
			paymentTx, commitIntent, err = d.paymentService.IntentCancel(p, 500*time.Millisecond)
			if err != nil {
				log.Error("error on intent payment cancel", log15.Ctx{"err": err})
				d.PaymentErrorHandler(p).ServeHTTP(w, r)
				return
			}
			err = d.paymentService.SetPaymentTransaction(tx, paymentTx)
			if err != nil {
				log.Error("error creating payment transaction", log15.Ctx{"err": err})
				d.InternalErrorHandler(p).ServeHTTP(w, r)
				return
			}
		}

		commit = true
		err = tx.Commit()
		if err != nil {
			log.Crit("error on commit", log15.Ctx{"err": err})
			d.InternalErrorHandler(p).ServeHTTP(w, r)
			return
		}

		// do notify on new payment tx
		if commitIntent != nil {
			if Debug {
				log.Debug("intent commit", log15.Ctx{"commitIntent": commitIntent})
			}
			commitIntent()
		}

		d.CancelPageHandler(p).ServeHTTP(w, r)
	})
}