package payment

import (
	"github.com/fritzpay/paymentd/pkg/server"
	"github.com/fritzpay/paymentd/pkg/service"
	"sync"
	"time"
)

var (
	waitTask sync.Once
)

type wait struct {
	ctx *service.Context
}

func (w *wait) run() {
	server.Wait.Add(1)
	w.ctx.Log().Info("starting wait task")
	<-w.ctx.Done()
	w.ctx.Log().Info("exiting wait task")
	time.Sleep(2 * time.Second)
	server.Wait.Done()
}

func startWait(ctx *service.Context) {
	waitTask.Do(func() {
		w := &wait{ctx: ctx}
		go w.run()
	})
}
