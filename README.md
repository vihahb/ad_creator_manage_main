# Campaign Manager - Offline Advertising Campaign Management System

A comprehensive Flutter application for managing offline advertising campaigns with sophisticated targeting capabilities and visual analytics.

## Features

### 1. Campaign Catalog Management
- **Create, Edit, and Store Campaigns** by multiple channels:
  - Business Cards
  - Direct Mail
  - Flyers
  - TV/Radio
  - Billboards
  - Events
  - Custom channels

- **Campaign Goals and Timeline**:
  - Define target audience and geographic locations
  - Set campaign timeline with start and end dates
  - Manage campaign budgets

- **Key Metrics Tracking**:
  - Impressions, clicks, conversions
  - Cost tracking and cost-per-click calculation
  - Automatic timestamp updates
  - Computed aggregate indicators (CTR, conversion rate)

- **Visual Analytics**:
  - Area charts for performance visualization using Syncfusion Charts
  - Time series analysis
  - Performance comparison charts
  - Funnel analysis

### 2. Local & Demographic Targeting Support
- **Geographic Targeting**:
  - Multiple location support per campaign
  - City, state, and region targeting
  - Location-based campaign filtering

- **Demographic Targeting**:
  - Age range targeting (min/max age)
  - Gender-based targeting
  - Occupation-based targeting
  - Interest-based targeting with multiple interests per campaign

- **Advanced Filtering**:
  - Filter campaigns by channel, location, and demographics
  - Search functionality across campaign names and channels
  - Comprehensive targeting visualization

## Technical Architecture

### Models
- **OfflineCampaign**: Core data model with Hive annotations for local storage
- Comprehensive field support for all targeting and metrics data
- Built-in computed properties for performance metrics

### Services
- **CampaignRepository**: Complete CRUD operations with Hive storage
- Advanced filtering and search capabilities
- Aggregate metrics calculation
- Time series data generation for charts

### Screens
1. **Campaign List Screen**: Main dashboard with search, filtering, and overview
2. **Campaign Form Screen**: Comprehensive creation/editing form with validation
3. **Campaign Details Screen**: Detailed view with performance charts and metrics
4. **Demo Screen**: Sample data initialization for demonstration
5. **Aggregate Charts Widget**: Analytics dashboard with multiple chart types

### Key Technologies
- **Flutter**: Cross-platform UI framework
- **Hive**: Local NoSQL database for offline storage
- **Syncfusion Charts**: Professional charting library for data visualization
- **Material Design**: Modern UI components and design system

## Installation

1. Ensure Flutter is installed on your system
2. Clone the repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to launch the application

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  syncfusion_flutter_charts: ^23.1.36

dev_dependencies:
  flutter_test:
    sdk: flutter
  lints: ^2.0.0
```

## Usage

### Creating a Campaign
1. Launch the app to see the Campaign Catalog
2. Tap the "+" button to create a new campaign
3. Fill in basic information (name, channel, budget, dates)
4. Add geographic targeting locations
5. Configure demographic targeting (age, gender, occupation, interests)
6. Save the campaign

### Managing Campaigns
- **View All Campaigns**: Browse the main catalog with search and filtering
- **Edit Campaigns**: Tap any campaign card to view details, then use the edit button
- **Update Metrics**: Edit existing campaigns to update performance metrics
- **Delete Campaigns**: Use the delete option in the edit screen

### Analytics and Reporting
- **Individual Campaign Analytics**: View detailed performance charts for each campaign
- **Aggregate Analytics**: Access the analytics dashboard from the main screen
- **Performance Comparison**: Compare multiple campaigns side-by-side
- **Time Series Analysis**: Track performance trends over time

### Targeting Features
- **Geographic**: Add multiple locations per campaign for precise geographic targeting
- **Demographic**: Set age ranges, gender preferences, occupation targeting
- **Interest-Based**: Tag campaigns with relevant interests for audience matching
- **Channel-Based**: Organize campaigns by advertising channel type

## Data Storage

The application uses Hive for local storage, providing:
- Fast, lightweight local database
- Offline-first functionality
- Type-safe data storage with custom adapters
- Cross-platform compatibility

## Charts and Visualization

Powered by Syncfusion Charts for professional data visualization:
- **Area Charts**: Performance metrics over time
- **Pie Charts**: Channel distribution analysis
- **Column Charts**: Campaign performance comparison
- **Funnel Charts**: Conversion funnel analysis
- **Interactive Features**: Tooltips, legends, and drill-down capabilities

## Sample Data

The demo screen automatically creates sample campaigns showcasing:
- Different advertising channels (Business Cards, Flyers, Direct Mail, etc.)
- Various geographic targeting (NYC, San Francisco, Los Angeles)
- Diverse demographic targeting scenarios
- Realistic performance metrics and costs

## Testing

Run the test suite with:
```bash
flutter test
```

Tests cover:
- Campaign repository operations (CRUD)
- Filtering and search functionality
- Metrics calculation accuracy
- Data persistence and retrieval
- Model validation and computed properties

## Future Enhancements

Potential areas for expansion:
- Integration with external analytics platforms
- Advanced reporting and export capabilities
- Campaign optimization recommendations
- Multi-user support and collaboration features
- Integration with actual advertising platforms
- Enhanced targeting with behavioral data

## Contributing

This project demonstrates a complete offline campaign management system with sophisticated targeting and analytics capabilities, suitable for marketing teams managing traditional advertising campaigns.