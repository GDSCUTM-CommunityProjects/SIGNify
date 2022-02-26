import pyrebase

firebaseConfig = {
    "apiKey": "AIzaSyD-u4ZvfCY1gvonlMfO1nApRSUwMR_1fw4",
    "authDomain": "signify-10529.firebaseapp.com",
    "databaseURL": "https://signify-10529.firebaseio.com",
    "projectId": "signify-10529",
    "storageBucket": "signify-10529.appspot.com",
    "messagingSenderId": "544688048548",
    "appId": "1:544688048548:web:dfc7c1be04f31c4cae5931"
}

# initialize firebase
firebase = pyrebase.initialize_app(firebaseConfig)
# access firebase authentication
auth = firebase.auth()


def register_account(email, password):
    try:
        # create user account in firebase
        user = auth.create_user_with_email_and_password(email, password)
        return True
    except:
        return False


def login_account(email, password):
    try:
        # verify user account
        login = auth.sign_in_with_email_and_password(email, password)
        return True
    except:
        return False