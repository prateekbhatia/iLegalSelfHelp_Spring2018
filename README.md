# iOS-master
iLegalSelfHelp iOS Source Code

tempServer2 - Web server required by Stripe to process transactions on the app. The server was hosted temporarily on Heroku under my account, and Stripe API key and some other (hardcoded) values will need to be updated to the latest web server and Stripe account details.

temporary_example - A sample project from the Internet to understand how Stripe integrates with iOS

Problem - Login to the app might fail if the DigitalOcean web server is down. In development phase until the server is back up, this can be avoided by skipping the network call and returning true for login
