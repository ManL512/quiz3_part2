from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from rest_framework_simplejwt.tokens import AccessToken, RefreshToken
from django.contrib.auth.models import User
from .serializers import UserSerializer
from datetime import timedelta
from django.utils.timezone import timedelta
import requests
from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework.exceptions import AuthenticationFailed
from django.contrib.auth import authenticate
from rest_framework.decorators import permission_classes
from rest_framework.permissions import IsAuthenticated

@api_view(['POST'])
def register(request):
    serializer = UserSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        user.set_password(request.data['password'])
        user.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
def login(request):
    username = request.data.get('username')
    password = request.data.get('password')

    if not username or not password:
        return Response({"error": "Please provide both username and password."}, status=status.HTTP_400_BAD_REQUEST)

    user = User.objects.filter(username=username).first()
    if not user or not user.check_password(password):
        return Response({"error": "Invalid credentials."}, status=status.HTTP_400_BAD_REQUEST)

    # Generar token de acceso y token de actualización
    access_token = AccessToken.for_user(user)
    access_token.set_exp(lifetime=timedelta(minutes=5))  # Duración del token de sesión: 5 minutos

    refresh_token = RefreshToken.for_user(user)

    return Response({
        "access_token": str(access_token),
        "refresh_token": str(refresh_token),
    }, status=status.HTTP_200_OK)

@api_view(['POST'])
def fingerprint_create(request):
    username = request.data.get('username')
    password = request.data.get('password')
    session_token = request.data.get('access_token')

    if not username or not password or not session_token:
        return Response({"error": "Por favor proporciona tu usuario, contraseña y token de acceso."}, status=status.HTTP_400_BAD_REQUEST)

    # Verificar si las credenciales son válidas
    user = User.objects.filter(username=username).first()
    if not user or not user.check_password(password):
        return Response({"error": "Credenciales inválidas."}, status=status.HTTP_400_BAD_REQUEST)

    # Verificar si el token de sesión es válido
    try:
        access_token = AccessToken(session_token)
    except Exception as e:
        return Response({"error": "Token de sesión inválido."}, status=status.HTTP_400_BAD_REQUEST)

    # Verificar si el token de sesión pertenece al usuario
    if access_token['user_id'] != user.id:
        return Response({"error": "El token de sesión no coincide con el usuario."}, status=status.HTTP_400_BAD_REQUEST)

    # Establecer la duración del token de acceso como 7 días
    access_token.set_exp(lifetime=timedelta(days=7))

    # Generar un nuevo token de sesión de larga duración
    long_session_token = AccessToken.for_user(user)
    long_session_token.set_exp(lifetime=timedelta(days=7))

    # Si todo es válido, devolver éxito con el token de sesión de larga duración
    return Response({"message": "Token de inicio de sesión generado.", "long_session_token": str(long_session_token)}, status=status.HTTP_200_OK)

@api_view(['POST'])
def fingerprint_login(request):
    username = request.data.get('username')
    long_session_token = request.data.get('long_session_token')

    if not username or not long_session_token:
        return Response({"error": "Por favor proporciona tu nombre de usuario y el token de inicio de sesion."}, status=status.HTTP_400_BAD_REQUEST)

    # Verificar si el usuario existe
    user = User.objects.filter(username=username).first()
    if not user:
        return Response({"error": "El usuario no existe."}, status=status.HTTP_400_BAD_REQUEST)

    # Verificar si el token de sesión largo es válido
    try:
        access_token = AccessToken(long_session_token)
    except Exception as e:
        return Response({"error": "Token de inicio de sesion inválido."}, status=status.HTTP_400_BAD_REQUEST)

    # Verificar si el token de sesión largo pertenece al usuario
    if access_token['user_id'] != user.id:
        return Response({"error": "El token de inicio de sesion no coincide con el usuario."}, status=status.HTTP_400_BAD_REQUEST)

    # Generar un token de sesión corto de 5 minutos
    short_session_token = AccessToken.for_user(user)
    short_session_token.set_exp(lifetime=timedelta(minutes=5))  # Duración del token de sesión corto de 5 minutos

    # Si todo es válido, devolver éxito con el token de sesión corto
    return Response({"message": "Inicio de sesión exitoso utilizando huella digital.", "access_token": str(short_session_token)}, status=status.HTTP_200_OK)

@api_view(['GET'])
def get_articles(request):
    try:
        # Verificar la autenticación del token de acceso
        jwt_authentication = JWTAuthentication()
        user, _ = jwt_authentication.authenticate(request)

        if user:
            # Hacer la solicitud GET al servicio de lista de artículos
            response = requests.get('https://api.npoint.io/237a0d1ac8530064cc04')
            
            if response.status_code == 200:
                articles = response.json()
                return Response(articles, status=status.HTTP_200_OK)
            else:
                return Response({"error": "No se pudo obtener la lista de artículos."}, status=response.status_code)
        else:
            raise AuthenticationFailed('Usuario no autenticado')
    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
    
@api_view(['GET'])
def get_offers(request):
    
    try:
        # Verificar la autenticación del token de acceso
        jwt_authentication = JWTAuthentication()
        user, _ = jwt_authentication.authenticate(request)

        if user:
            # Hacer la solicitud GET al servicio de lista de artículos
            response = requests.get('https://api.npoint.io/237a0d1ac8530064cc04')
            
            if response.status_code == 200:
                articles = response.json()
                return Response(articles, status=status.HTTP_200_OK)
            else:
                return Response({"error": "No se pudo obtener la lista de ofertas."}, status=response.status_code)
        else:
            raise AuthenticationFailed('Usuario no autenticado')
    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
    
@api_view(['POST'])
def logout(request):
    # Obtiene el token de acceso del encabezado de autorización
    authorization_header = request.headers.get('Authorization')
    if not authorization_header:
        return Response({"error": "El encabezado de autorización no está presente."}, status=status.HTTP_400_BAD_REQUEST)

    try:
        # Extrae el token de acceso del encabezado
        access_token = authorization_header.split(' ')[1]

        # Verifica si el token de acceso es válido
        AccessToken(access_token)

        # Si el token es válido, lo invalida (borrándolo)
        # Aquí podrías agregar más acciones como registrar la acción de logout, etc.
        # Por ahora, simplemente devuelve un mensaje de éxito
        return Response({"message": "Cierre de sesión exitoso."}, status=status.HTTP_200_OK)

    except AuthenticationFailed:
        # Si el token de acceso no es válido, devuelve un error
        return Response({"error": "Token de acceso inválido."}, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        # Si ocurre un error inesperado, devuelve un mensaje de error genérico
        return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)