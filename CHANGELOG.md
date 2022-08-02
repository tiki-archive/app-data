## 0.0.21

* add onError control for accounts
* improve account status
* strategy_google 0.0.15
* strategy_microsoft 0.1.13

## 0.0.20

* disconnect account that can't refresh
* stop all commands when account is disconnected
* process emails that doesn't have the current connected account as recipient
* strategy_google 0.0.13
* strategy_microsoft 0.1.11

## 0.0.19

* strategy_google 0.1.11

## 0.0.18

* update dependencies

## 0.0.17

* check non ignored senders before adding spam cards
* start indexing from last indexed page
* strategy_microsoft 0.1.10
* strategy_google 0.1.10

## 0.0.16

* update dependencies

## 0.0.15

* set domain name in repository to be one returned from big picture
* strategy_microsoft 0.0.17 
* strategy_google 0.0.16

## 0.0.14

* improve created_signals event

## 0.0.13

* fix company service unique constraint error
* improve enrichapi logs
* update tiki decision to 0.0.13

## 0.0.12

* fix decision cards creation
* remove multi account UI

## 0.0.11

* fix missing updates

## 0.0.10

* add command slice
* implement CommandManagerService
* implement CommandFetchInbox and CommandFetchMsg
* prepare for multiple accounts
* update error log
* add data pipeline monitoring

## 0.0.9

* fixed init bugs
* remove data on unlink
* don't show unsubscribed cards

## 0.0.8

* added push to localgraph
* added subject persist

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

