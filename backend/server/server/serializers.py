#serializers.py
from rest_framework import serializers
from django.contrib.auth.models import User
from rest_framework_simplejwt.tokens import AccessToken

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'password']

class SessionTokenSerializer(serializers.Serializer):
    access_token = serializers.CharField()
