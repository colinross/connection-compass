= Proof of concept

== Basic Architecture
- Ruby 1.9, Rails 3 -or- even just Sinatra
- memcached/redis for transparent request caching
- couchdb for persistance [Contacts, Members, Credentials]

== Data Models
- Contact : abstracted 'person', based on a Facebook 'Friend', Twitter 'Follower', LinkedIn 'Connection', etc.
- Member : A registered user of the application
- Service : abstracted 'api' used as a source of data: FB, Twitter, LinkedIn, etc. API
- Credentials : an encrypted store of the credentials needed to connect to a `Service` as the `Member` to retrieve `Contacts` 

== Utilities
- CachingHttpClient: transparently cache api requests in front of the standard Net::HTTP library (see https://github.com/umut/http-cache)

== Services
- RegisterMemberService
- AuthenticateMemberService (Oauth client/tokening system)
- StoreFacebookContactService: converts raw json/xml response into a Contact object, also think StoreTwitterContactService  [AbstractContactStorageService]


== Authentication
- Whilst the account has a concept of a registered 'user' all authentication is done using third-party resources (OAuth mainly) So a user logs in with their facebook/twitter/linkedin account.
