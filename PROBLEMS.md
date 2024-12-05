### Please describe found weak places below.

#### Security issues

1. Missing CSRF token validation which ensures that actions requiring user trust (like financial transactions, sensitive data changes, or privileged actions) can only be performed by the intended user. Another option is to use auth system and would suggest Devise gem
2. `params[:transaction].permit!` allows to pass any parameters to the transaction creation. It is better to permit only required parameters based on `params[:type]`. For example if params has updated_at with other value it may alter it in the db which is not expected.
3. As transactions should have unique id I would suggest using `SecureRandom.uuid` instead of `SecureRandom.hex` to avoid collisions
4. add unique index to uid field on transactions table
5. The app has volnurability to DDOS attacks as it does not have rate limiting for transactions creation or any other actions. Adding captcha can be a good idea too.
6. transaction id in view should be replaced with uid to avoid exposing internal ids. If the user gets the internal id they can tell how many transactions have been happened before, which can be considered as a security issue.
7. as there is params[:type] variable which is coming from requests added a validation to ensure that it is one of the allowed types to avoid rendering other templates.


#### Performance issues

1. `Manager.all.sample` loads all managers and takes random ones. Instead it is better to get random one directly from database. Assigned manager in backend on save action only as its being selected randomly anyway.
2. `Transaction.all` loads all transactions skipping getting required managers and thus allowing N + 1 queries. So in this specific situation is better to use includes(:manager) to get all transactions with managers in one query. We can use benchmarks to check if it is better to use includes or joins too.
3. If transactions gets bigger it is better to add indexes to the database to speed up queries and use pagination by providing limit and offset to the query
4. Partitioning transactions table by creation date can be a good idea if it gets too big to speed up queries
5. Order transactions by creation date and add an index to it to speed up queries
6. I would suggest loading transactions in batches and stream them via websockets to the client to avoid loading all transactions at once, ActionCable can be used for this purpose. 


#### Code issues

1. There is a repetition getting random manager or setting up a new Transaction. This can be solved by adding descriptive methods and using them before actions that require them.
2. If the transactions creation process gets more complex, it is better to move it to a separate service class and add checkings specs there
3. In views we can use partials to avoid code repetition, for example from_amount, to_currency inputs are used in all 3 forms. Transactions links list can be extracted to a partial too.
4. AS we are not showing random chosen manager in view its not neccessary to get it in controller for views, instead it can be applied during post request in transaction creation service or model.
5. instead of throwing rails errors directly to the user its better to show an error message explaining what went wrong in a user-friendly way
6. Transaction model seems doing conversion itself which can be moved to ConversionBuilder or similar service to make it more modular and testable. Models action mostly is to save and validate data.
#### Others

1. if url is not currect it raises error which is visible to end user. It should show 404 page instead.
2. Use rubocop with specified config to ensure code style consistency and readability
3. Add specs to models controllers and potential services if needed.
4. No need to use hardcoded numbers, they are not descriptive and may lead potential bugs if changed in one place and not in another
5. If the same user has multiple transactions we will get the same user several types having repetitions. This is against db normalization rules though it will load transactions faster. It is better to have separate table for users and transactions and link them with foreign key.
6. I would add an api with an access token to allow users to create/retrieve transactions from other services or apps
7. Dockerization can be a good idea to make the app more portable and easy to deploy, For development environment I prefer docker-compose
