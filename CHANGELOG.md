## 0.0.3

* Bug fixes for access token and refresh

## 0.0.2

* Fixed bugs in data fetch
* Fixed bugs in link state mgmt
* Added ability to load spam cards from DB
* Updated to new spam_cards api

## 0.0.1

* Base functionality implemented. 
* Works but is not ready for prod.
* Known bugs:
  * fetchs get stuck in infinite loop with bad tokens
  * accounts can fail to link and fetches start anyways
  * fetches continue after unlink
  * sender upsert overwrite "since" timestamp
  * spam cards are not fed from already saved emails on startup

