-- MySQL Script generated by MySQL Workbench
-- Wed 29 Oct 2014 06:46:22 PM CET
-- Model: New Model    Version: 1.0
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema fritzpay_payment
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema fritzpay_principal
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Table `config`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `config` ;

CREATE TABLE IF NOT EXISTS `config` (
  `name` VARCHAR(64) NOT NULL,
  `last_change` BIGINT UNSIGNED NOT NULL,
  `value` TEXT NULL,
  PRIMARY KEY (`name`, `last_change`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `provider`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `provider` ;

CREATE TABLE IF NOT EXISTS `provider` (
  `name` VARCHAR(64) NOT NULL,
  PRIMARY KEY (`name`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `payment_method`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `payment_method` ;

CREATE TABLE IF NOT EXISTS `payment_method` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `project_id` INT UNSIGNED NOT NULL,
  `provider` VARCHAR(64) NOT NULL,
  `method_key` VARCHAR(64) NOT NULL,
  `created` DATETIME NOT NULL,
  `created_by` VARCHAR(64) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_payment_method_project_id_idx` (`project_id` ASC),
  UNIQUE INDEX `method_key` (`project_id` ASC, `provider` ASC, `method_key` ASC),
  INDEX `fk_payment_method_provider_idx` (`provider` ASC),
  CONSTRAINT `fk_payment_method_provider`
    FOREIGN KEY (`provider`)
    REFERENCES `provider` (`name`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `currency`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `currency` ;

CREATE TABLE IF NOT EXISTS `currency` (
  `code_iso_4217` VARCHAR(3) NOT NULL,
  PRIMARY KEY (`code_iso_4217`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `payment_method_status`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `payment_method_status` ;

CREATE TABLE IF NOT EXISTS `payment_method_status` (
  `payment_method_id` BIGINT UNSIGNED NOT NULL,
  `timestamp` BIGINT UNSIGNED NOT NULL,
  `created_by` VARCHAR(64) NOT NULL,
  `status` VARCHAR(32) NOT NULL,
  PRIMARY KEY (`payment_method_id`, `timestamp`),
  CONSTRAINT `fk_payment_method_status_payment_method_id`
    FOREIGN KEY (`payment_method_id`)
    REFERENCES `payment_method` (`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `payment_method_metadata`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `payment_method_metadata` ;

CREATE TABLE IF NOT EXISTS `payment_method_metadata` (
  `payment_method_id` BIGINT UNSIGNED NOT NULL,
  `name` VARCHAR(64) NOT NULL,
  `timestamp` BIGINT UNSIGNED NOT NULL,
  `created_by` VARCHAR(64) NOT NULL,
  `value` TEXT NOT NULL,
  PRIMARY KEY (`payment_method_id`, `name`, `timestamp`),
  CONSTRAINT `fk_principal_metadata_payment_method_id`
    FOREIGN KEY (`payment_method_id`)
    REFERENCES `payment_method` (`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `payment`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `payment` ;

CREATE TABLE IF NOT EXISTS `payment` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `project_id` INT UNSIGNED NOT NULL,
  `created` DATETIME NOT NULL,
  `ident` VARCHAR(175) NOT NULL,
  `amount` INT NOT NULL,
  `subunits` TINYINT(4) UNSIGNED NOT NULL,
  `currency` VARCHAR(3) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `created` (`created` ASC),
  UNIQUE INDEX `ident` (`project_id` ASC, `ident` ASC),
  INDEX `fk_payment_currency_idx` (`currency` ASC),
  UNIQUE INDEX `payment_id` (`project_id` ASC, `id` ASC),
  CONSTRAINT `fk_payment_currency`
    FOREIGN KEY (`currency`)
    REFERENCES `currency` (`code_iso_4217`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `payment_config`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `payment_config` ;

CREATE TABLE IF NOT EXISTS `payment_config` (
  `project_id` INT UNSIGNED NOT NULL,
  `payment_id` BIGINT UNSIGNED NOT NULL,
  `timestamp` BIGINT UNSIGNED NOT NULL,
  `payment_method_id` BIGINT UNSIGNED NULL,
  `country` VARCHAR(2) NULL,
  `locale` VARCHAR(5) NULL,
  `callback_url` TEXT NULL,
  `callback_api_version` VARCHAR(32) NULL,
  `callback_project_key` VARCHAR(64) NULL,
  `return_url` TEXT NULL,
  `expires` DATETIME NULL,
  PRIMARY KEY (`project_id`, `payment_id`, `timestamp`),
  INDEX `fk_payment_config_payment_method_id_idx` (`payment_method_id` ASC),
  INDEX `fk_payment_config_payment_id_idx` (`payment_id` ASC),
  CONSTRAINT `fk_payment_config_payment_id`
    FOREIGN KEY (`payment_id`)
    REFERENCES `payment` (`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_payment_config_payment_method_id`
    FOREIGN KEY (`payment_method_id`)
    REFERENCES `payment_method` (`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `payment_metadata`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `payment_metadata` ;

CREATE TABLE IF NOT EXISTS `payment_metadata` (
  `project_id` INT UNSIGNED NOT NULL,
  `payment_id` BIGINT UNSIGNED NOT NULL,
  `name` VARCHAR(125) NOT NULL,
  `timestamp` BIGINT UNSIGNED NOT NULL,
  `value` TEXT NULL,
  PRIMARY KEY (`project_id`, `payment_id`, `name`, `timestamp`),
  INDEX `fk_payment_metadata_payment_id_idx` (`payment_id` ASC),
  INDEX `timestamp` (`project_id` ASC, `payment_id` ASC, `timestamp` ASC),
  CONSTRAINT `fk_payment_metadata_payment_id`
    FOREIGN KEY (`payment_id`)
    REFERENCES `payment` (`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `payment_token`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `payment_token` ;

CREATE TABLE IF NOT EXISTS `payment_token` (
  `token` VARCHAR(64) NOT NULL,
  `created` DATETIME NOT NULL,
  `project_id` INT UNSIGNED NOT NULL,
  `payment_id` BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (`token`),
  INDEX `created` (`created` ASC),
  INDEX `fk_payment_token_payment_id_idx` (`payment_id` ASC),
  INDEX `fk_payment_token_project_id_idx` (`project_id` ASC),
  CONSTRAINT `fk_payment_token_payment_id`
    FOREIGN KEY (`payment_id`)
    REFERENCES `payment` (`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `payment_transaction`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `payment_transaction` ;

CREATE TABLE IF NOT EXISTS `payment_transaction` (
  `project_id` INT UNSIGNED NOT NULL,
  `payment_id` BIGINT UNSIGNED NOT NULL,
  `timestamp` BIGINT UNSIGNED NOT NULL,
  `amount` INT NOT NULL,
  `subunits` TINYINT(4) UNSIGNED NOT NULL,
  `currency` VARCHAR(3) NOT NULL,
  `status` VARCHAR(32) NOT NULL,
  `comment` TEXT NULL,
  PRIMARY KEY (`project_id`, `payment_id`, `timestamp`),
  INDEX `status` (`status` ASC),
  INDEX `fk_payment_transaction_currency_idx` (`currency` ASC),
  INDEX `fk_payment_transaction_payment_id_idx` (`payment_id` ASC),
  CONSTRAINT `fk_payment_transaction_payment_id`
    FOREIGN KEY (`payment_id`)
    REFERENCES `payment` (`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_payment_transaction_currency`
    FOREIGN KEY (`currency`)
    REFERENCES `currency` (`code_iso_4217`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `provider_fritzpay_payment`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `provider_fritzpay_payment` ;

CREATE TABLE IF NOT EXISTS `provider_fritzpay_payment` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `project_id` INT UNSIGNED NOT NULL,
  `payment_id` BIGINT UNSIGNED NOT NULL,
  `created` DATETIME NOT NULL,
  `method_key` VARCHAR(64) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_provider_fritzpay_payment_payment_id_idx` (`payment_id` ASC),
  UNIQUE INDEX `payment_id` (`project_id` ASC, `payment_id` ASC),
  CONSTRAINT `fk_provider_fritzpay_payment_payment_id`
    FOREIGN KEY (`payment_id`)
    REFERENCES `payment` (`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
COMMENT = 'Stores payments made with the FritzPay demo provider.';


-- -----------------------------------------------------
-- Table `provider_fritzpay_transaction`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `provider_fritzpay_transaction` ;

CREATE TABLE IF NOT EXISTS `provider_fritzpay_transaction` (
  `fritzpay_payment_id` BIGINT UNSIGNED NOT NULL,
  `timestamp` BIGINT UNSIGNED NOT NULL,
  `status` VARCHAR(32) NOT NULL,
  `fritzpay_id` VARCHAR(64) NULL COMMENT 'This would be the ID which identifies the payment on the provider.',
  `payload` TEXT NULL,
  PRIMARY KEY (`fritzpay_payment_id`, `timestamp`),
  INDEX `fritzpay_id` (`fritzpay_id` ASC),
  INDEX `status` (`status` ASC),
  CONSTRAINT `fk_provider_fritzpay_transaction_fritzpay_payment_id`
    FOREIGN KEY (`fritzpay_payment_id`)
    REFERENCES `provider_fritzpay_payment` (`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `provider_paypal_transaction`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `provider_paypal_transaction` ;

CREATE TABLE IF NOT EXISTS `provider_paypal_transaction` (
  `project_id` INT UNSIGNED NOT NULL,
  `payment_id` BIGINT UNSIGNED NOT NULL,
  `timestamp` BIGINT UNSIGNED NOT NULL,
  `type` VARCHAR(32) NOT NULL,
  `nonce` VARCHAR(32) NULL,
  `intent` VARCHAR(32) NULL,
  `paypal_id` VARCHAR(128) NULL,
  `payer_id` VARCHAR(64) NULL,
  `paypal_create_time` DATETIME NULL,
  `paypal_state` VARCHAR(32) NULL,
  `paypal_update_time` DATETIME NULL,
  `links` TEXT NULL,
  `data` TEXT NULL,
  PRIMARY KEY (`project_id`, `payment_id`, `timestamp`),
  INDEX `paypal_id` (`paypal_id` ASC),
  INDEX `paypal_state` (`paypal_state` ASC),
  INDEX `fk_provider_paypal_transaction_payment_id_idx` (`payment_id` ASC),
  INDEX `paypal_payer_id` (`payer_id` ASC),
  INDEX `paypal_intent` (`intent` ASC),
  INDEX `paypal_nonce` (`project_id` ASC, `payment_id` ASC, `nonce` ASC),
  INDEX `type` (`project_id` ASC, `payment_id` ASC, `type` ASC),
  CONSTRAINT `fk_provider_paypal_transaction_payment_id`
    FOREIGN KEY (`payment_id`)
    REFERENCES `payment` (`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `provider_paypal_authorization`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `provider_paypal_authorization` ;

CREATE TABLE IF NOT EXISTS `provider_paypal_authorization` (
  `project_id` INT UNSIGNED NOT NULL,
  `payment_id` BIGINT UNSIGNED NOT NULL,
  `timestamp` BIGINT UNSIGNED NOT NULL,
  `valid_until` DATETIME NOT NULL,
  `state` VARCHAR(32) NOT NULL,
  `authorization_id` VARCHAR(128) NOT NULL,
  `paypal_id` VARCHAR(128) NOT NULL,
  `amount` VARCHAR(64) NOT NULL,
  `currency` VARCHAR(3) NOT NULL,
  `links` TEXT NULL,
  `data` TEXT NULL,
  PRIMARY KEY (`project_id`, `payment_id`, `timestamp`),
  INDEX `fk_provider_paypal_authorization_payment_id_idx` (`payment_id` ASC),
  CONSTRAINT `fk_provider_paypal_authorization_payment_id`
    FOREIGN KEY (`payment_id`)
    REFERENCES `payment` (`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
-- Data for table `provider`
-- -----------------------------------------------------
START TRANSACTION;
INSERT INTO `provider` (`name`) VALUES ('fritzpay');
INSERT INTO `currency` (`code_iso_4217`) VALUES ('EUR');

COMMIT;

