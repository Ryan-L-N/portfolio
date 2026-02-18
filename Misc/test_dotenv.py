from dotenv import load_dotenv
import os

#This function call loads environment variables in a .env file into the Python Script
load_dotenv()

#You can then load each environment variable by using the .getenv method and adding in the environment
#variable's name
TEST = os.getenv("TEST_VAR")

print(TEST)