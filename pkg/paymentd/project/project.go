package project

import (
	"database/sql"
	"encoding/hex"
	"encoding/json"
	"time"
)

const (
	metadataTable        = "project_metadata"
	metadataPrimaryField = "project_id"
)

// Project represents a project
//
// A project is a resource of a principle.
// It has its payment methodes and can be used to separate
// different business units of one principle
type Project struct {
	ID          int64 `json:",string"`
	PrincipalID int64 `json:",string"`
	Name        string
	Created     time.Time
	CreatedBy   string

	Config Config

	Metadata map[string]string
}

// Empty returns true if the project is considered empty/uninitialized
func (p *Project) Empty() bool {
	return p.ID == 0 && p.Name == ""
}

type Config struct {
	Timestamp          time.Time
	WebURL             sql.NullString
	CallbackURL        sql.NullString
	CallbackAPIVersion sql.NullString
	CallbackProjectKey sql.NullString
	ReturnURL          sql.NullString
}

type ConfigJSON struct {
	WebURL             *string
	CallbackURL        *string
	CallbackAPIVersion *string
	CallbackProjectKey *string
	ReturnURL          *string
}

// IsSet returns true if the config was set and stored
func (c Config) IsSet() bool {
	return !c.Timestamp.IsZero()
}

// HasValues returns true if the config has any values set
func (c Config) HasValues() bool {
	return c.WebURL.Valid || c.CallbackURL.Valid || c.CallbackAPIVersion.Valid || c.CallbackProjectKey.Valid || c.ReturnURL.Valid
}

func (c Config) HasCallback() bool {
	return c.CallbackURL.Valid && c.CallbackAPIVersion.Valid && c.CallbackProjectKey.Valid
}

func (c Config) CallbackConfig() (url, version, projectKey string) {
	return c.CallbackURL.String, c.CallbackAPIVersion.String, c.CallbackProjectKey.String
}

func (c *Config) SetWebURL(webURL string) {
	c.WebURL.String, c.WebURL.Valid = webURL, true
}

func (c *Config) SetCallbackURL(callbackURL string) {
	c.CallbackURL.String, c.CallbackURL.Valid = callbackURL, true
}

func (c *Config) SetCallbackAPIVersion(ver string) {
	c.CallbackAPIVersion.String, c.CallbackAPIVersion.Valid = ver, true
}

func (c *Config) SetCallbackProjectKey(key string) {
	c.CallbackProjectKey.String, c.CallbackProjectKey.Valid = key, true
}

func (c *Config) SetReturnURL(url string) {
	c.ReturnURL.String, c.ReturnURL.Valid = url, true
}

func (c *Config) UnmarshalJSON(p []byte) error {
	cfg := &ConfigJSON{}
	err := json.Unmarshal(p, cfg)
	if err != nil {
		return err
	}
	if cfg.WebURL != nil {
		c.SetWebURL(*cfg.WebURL)
	}
	if cfg.CallbackURL != nil {
		c.SetCallbackURL(*cfg.CallbackURL)
	}
	if cfg.CallbackAPIVersion != nil {
		c.SetCallbackAPIVersion(*cfg.CallbackAPIVersion)
	}
	if cfg.CallbackProjectKey != nil {
		c.SetCallbackProjectKey(*cfg.CallbackProjectKey)
	}
	if cfg.ReturnURL != nil {
		c.SetReturnURL(*cfg.ReturnURL)
	}
	return nil
}

func (c Config) MarshalJSON() ([]byte, error) {
	cfg := &ConfigJSON{}
	if c.WebURL.Valid {
		cfg.WebURL = &c.WebURL.String
	}
	if c.CallbackURL.Valid {
		cfg.CallbackURL = &c.CallbackURL.String
	}
	if c.CallbackAPIVersion.Valid {
		cfg.CallbackAPIVersion = &c.CallbackAPIVersion.String
	}
	if c.CallbackProjectKey.Valid {
		cfg.CallbackProjectKey = &c.CallbackProjectKey.String
	}
	if c.ReturnURL.Valid {
		cfg.ReturnURL = &c.ReturnURL.String
	}
	return json.Marshal(cfg)
}

// representation of the metadata schema structure
const MetadataModel metadataModel = 0

// pattern for nicer package usage
// this prevents the initialistation of a struct object{}
// instead devs can just take the MetadataModel const
type metadataModel int

func (m metadataModel) Table() string {
	return metadataTable
}

func (m metadataModel) PrimaryField() string {
	return metadataPrimaryField
}

// ProjectKey represents a project key
type Projectkey struct {
	Key         string
	Timestamp   time.Time
	Project     Project
	CreatedBy   string
	Secret      string
	secretBytes []byte
	Active      bool
}

// IsValid returns true if the project key is considered valid
func (p *Projectkey) IsValid() bool {
	return p.Key != "" && p.Active
}

// SecretBytes returns the binary representation of the shared secret
func (p *Projectkey) SecretBytes() ([]byte, error) {
	return hex.DecodeString(p.Secret)
}
