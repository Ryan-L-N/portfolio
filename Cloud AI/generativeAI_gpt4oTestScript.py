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
    messages=[
        {
            "role": "system",
            "content": "You are a helpful assistant.",
        },
        {
            "role": "user",
            "content": "I am going to Paris, what should I see?",
        }
    ],
    max_tokens=4096,
    temperature=1.0,
    top_p=1.0,
    model=deployment
)

print(response.choices[0].message.content)