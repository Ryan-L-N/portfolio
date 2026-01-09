import os
from openai import AzureOpenAI

subscription_key = 'CHX7D9138qZtPaVXT6vsGbDasVc11vPMh4f4lnKiPomnWNvg1LVdJQQJ99CAACHYHv6XJ3w3AAAAACOG4DxW'
endpoint = "https://nevilletestproject2-resource.cognitiveservices.azure.com/"
model_name = "gpt-4o"
deployment = "gpt-4o"
api_version = "2024-12-01-preview"

client = AzureOpenAI(
    api_version=api_version,
    azure_endpoint=endpoint,
    api_key=subscription_key,
)

response = client.chat.completions.create(
    stream=True,
    messages=[
        {
            "role": "system",
            "content": "You are a helpful assistant.",
        },
        {
            "role": "user",
            "content": "I am thinking about moving to Pittsburgh, where should I buy a home?  What things should I consider?",
        }
    ],
    max_tokens=4096,
    temperature=1.0,
    top_p=1.0,
    model=deployment,
)

for update in response:
    if update.choices:
        print(update.choices[0].delta.content or "", end="")

client.close()