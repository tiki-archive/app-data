## 0.0.1

* Base functionality implemented. 
* Works but is not ready for prod.
* Known bugs:
  * fetchs get stuck in infinite loop with bad tokens
  * accounts can fail to link and fetches start anyways
  * fetches continue after unlink
  * sender upsert overwrite "since" timestamp
  * spam cards are not fed from already saved emails on startup

