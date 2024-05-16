#urls.py
from django.urls import path
from . import views

urlpatterns = [
    path('register', views.register), 
    path('login', views.login),
    path('fingerprint-create', views.fingerprint_create),
    path('fingerprint-login', views.fingerprint_login),
    path('get-articles', views.get_articles),
    path('get-offers', views.get_offers),
    path('logout', views.logout)
]
