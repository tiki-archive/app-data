## 0.0.7

* fixed issues with spam card callbacks
* fixed bug with bool persistence in email sender

## 0.0.6

* Version bump decision & spam card

## 0.0.5

* Fixed bug with setting linked state on load

## 0.0.4

* Bumped google, microsoft, spam, and decision versions

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

