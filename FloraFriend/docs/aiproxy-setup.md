# AIProxy Setup Guide for FloraFriend

This guide explains how to integrate AIProxy with FloraFriend for plant identification using OpenAI's vision capabilities.

## Prerequisites

1. **AIProxy Account**: Sign up at [aiproxy.com](https://aiproxy.com)
2. **OpenAI API Key**: Get your API key from [OpenAI Platform](https://platform.openai.com)
3. **Xcode Project**: Ensure you have the FloraFriend Xcode project ready

## Step 1: Add AIProxy Swift Package

1. Open your Xcode project
2. Go to **File > Add Package Dependencies**
3. Enter the AIProxy Swift package URL: `https://github.com/lzell/AIProxySwift`
4. Click **Add Package** and add it to your target

## Step 2: Configure AIProxy Service

1. **Get your AIProxy credentials** from your AIProxy dashboard:
   - Service URL (e.g., `https://your-service.aiproxy.com`)
   - Partial Key (provided by AIProxy)

2. **Update the configuration** in `PlantIdentificationService.swift`:

```swift
// Replace these values in PlantIdentificationConfig
struct PlantIdentificationConfig {
    static let partialKey = "your-actual-partial-key-here"
    static let serviceURL = "https://your-service.aiproxy.com"
}
```

## Step 3: Test the Integration

1. **Build and run** your app
2. **Take a photo** of a plant using the camera feature
3. **Check the console** for any error messages
4. **Verify the response** contains proper plant identification data

## API Response Structure

The service returns a `PlantIdentificationResponse` with the following structure:

```swift
struct PlantIdentificationResponse: Codable {
    let commonName: String
    let scientificName: String
    let plantDescription: String
    let confidence: Double
    let careInstructions: CareInstructions
    let characteristics: PlantCharacteristics
    let safetyInfo: SafetyInformation
    let habitat: String
    let origin: String
    let classification: ScientificClassification
    let uses: [PlantUse]
    let priceRange: PriceRange
    let careLevel: String
}
```

## Error Handling

The service handles various error scenarios:

- **Image Processing Failed**: Image couldn't be processed
- **Authentication Failed**: Invalid AIProxy credentials
- **Rate Limit Exceeded**: Too many requests
- **Decoding Error**: Response format issues
- **AI Proxy Error**: General AIProxy service errors

## Security Best Practices

1. **Never commit credentials** to version control
2. **Use environment variables** for production builds
3. **Implement proper error handling** for user experience
4. **Monitor API usage** to avoid unexpected costs

## Troubleshooting

### Common Issues:

1. **Authentication Error**
   - Verify your partial key and service URL
   - Check AIProxy dashboard for account status

2. **Rate Limiting**
   - Implement request throttling in your app
   - Consider caching results for recently identified plants

3. **Large Images**
   - Ensure image compression (currently set to 0.8 quality)
   - Consider resizing images before processing

4. **Network Connectivity**
   - Add proper network error handling
   - Implement offline mode with cached data

## Production Considerations

1. **Environment Configuration**: Use different keys for development/production
2. **Caching Strategy**: Cache identified plants to reduce API calls
3. **Performance Optimization**: Implement image preprocessing
4. **User Experience**: Add loading states and progress indicators

## Support

- **AIProxy Documentation**: [aiproxy.com/docs](https://aiproxy.com/docs)
- **OpenAI API Reference**: [OpenAI Vision API](https://platform.openai.com/docs/guides/vision)
- **Swift Package**: [AIProxySwift GitHub](https://github.com/lzell/AIProxySwift)