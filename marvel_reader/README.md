# README


Hello, 
this is my implementation based on my understanding of the specification and the provided assets.

This is a standart rails 5 application with jquery.


Calls for the Marvel api, are stored in rails cache;
 the favorites list is kept in a local DB table, and mashed with the api results on each call;
 has have I have not implemented authentication, each comic, can only be marked as favorite once.


*Points of improvement:
The images used are from the links provided by the api.
A local storage, with image resizing and oportunistic caching, could improve performance, by reducing the size of the images to download.


* Configuration
 Ruby 2.3.1, with rails 5
 just run bundle install, to set all the required gems and rake db:create/rake db:migrate to create the database
