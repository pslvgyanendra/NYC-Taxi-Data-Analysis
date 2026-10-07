# 🚕 NYC Taxi Data Analysis

### 📊 End-to-End Data Analytics Project | Python • SQL • Power BI

An end-to-end **NYC Taxi Data Analysis** project focused on analyzing taxi demand, passenger behavior, trip distance, revenue, payment methods, pickup/drop-off zones, and peak travel patterns.

The project combines **Data Cleaning, Exploratory Data Analysis, SQL Analysis, DAX, and Interactive Power BI Dashboards** to transform raw taxi trip data into meaningful business insights.

---

## 📌 Project Overview

NYC Taxi trip data contains detailed information about taxi journeys, including pickup and drop-off locations, trip distance, fare amount, passenger count, payment method, and timestamps.

The objective of this project is to answer key business questions such as:

- 🚕 When is taxi demand highest?
- 📍 Which pickup and drop-off zones generate the most trips?
- ⏰ What are the peak hours for taxi demand?
- 💰 How much revenue is generated?
- 🛣️ What is the average trip distance?
- 💳 Which payment methods are most commonly used?
- 📈 How does trip demand change throughout the day?
- 🏙️ Which locations contribute most to overall taxi activity?

---

# 🎯 Business Objectives

The analysis focuses on five major areas:

### 1️⃣ Demand Analysis

Understand taxi demand by:

- Hour
- Day of Week
- Pickup Zone
- Drop-off Zone
- Trip Frequency

### 2️⃣ Revenue Analysis

Analyze:

- Total Revenue
- Average Fare
- Average Trip Amount
- Tip Amount
- Revenue Contribution

### 3️⃣ Trip Analysis

Evaluate:

- Average Trip Distance
- Trip Duration
- Passenger Count
- Fare vs Distance
- Distance vs Duration

### 4️⃣ Location Analysis

Identify:

- Top Pickup Zones
- Top Drop-off Zones
- Most Active Locations
- Location-Level Demand Patterns

### 5️⃣ Customer & Payment Analysis

Analyze:

- Passenger Distribution
- Payment Methods
- Tip Behavior
- Fare Patterns

---

# 🛠️ Tools & Technologies

| Technology | Purpose |
|---|---|
| 🐍 **Python** | Data Cleaning & EDA |
| 🐼 **Pandas** | Data Manipulation |
| 🔢 **NumPy** | Numerical Analysis |
| 🗄️ **SQL** | Data Analysis & Querying |
| 📊 **Power BI** | Interactive Dashboard |
| ⚡ **Power Query** | Data Transformation |
| 📐 **DAX** | Measures & KPIs |
| 📓 **Jupyter Notebook** | Python Analysis |
| 🐙 **Git & GitHub** | Version Control & Portfolio |

---

# 🔄 Project Workflow

```text
Raw NYC Taxi Data
        ↓
Data Understanding
        ↓
Data Profiling
        ↓
Data Cleaning
        ↓
Data Transformation
        ↓
Data Validation
        ↓
SQL Analysis
        ↓
Exploratory Data Analysis
        ↓
DAX & KPI Development
        ↓
Power BI Dashboard
        ↓
Business Insights
        ↓
Recommendations
```

---

# 🧹 Data Cleaning

Several data quality issues were identified and addressed during preprocessing.

### Major Cleaning Activities

- Removed duplicate records
- Handled missing values
- Corrected data types
- Converted date/time columns
- Created pickup and drop-off time attributes
- Identified invalid and negative values
- Investigated suspicious zero trip distances
- Created trip duration
- Validated passenger counts
- Checked fare and revenue-related fields
- Standardized categorical values
- Created analytical columns required for dashboarding

---

# 📊 Key KPIs

The Power BI dashboard includes important business metrics.

### 🚕 Trip KPIs

- **Total Trips**
- **Average Trip Distance**
- **Average Trip Duration**
- **Average Passengers per Trip**

### 💰 Revenue KPIs

- **Total Revenue**
- **Average Fare**
- **Average Tip**
- **Average Trip Amount**

### 📍 Location KPIs

- **Top Pickup Zone**
- **Top Drop-off Zone**
- **Most Active Locations**

### ⏰ Demand KPIs

- **Peak Hour**
- **Peak Demand Period**
- **Trips by Hour**
- **Trips by Location**

---

# 📈 Power BI Dashboard

The Power BI dashboard provides an interactive view of NYC taxi operations and demand patterns.

## 📄 Dashboard Pages

### 🏠 1. Overview

Provides a high-level summary of:

- Total Trips
- Total Revenue
- Average Trip Distance
- Average Fare
- Trip Trends
- Revenue Trends

### 🚕 2. Demand Analysis

Focuses on taxi demand patterns.

Key visuals include:

- Trips by Hour
- Peak Hour
- Top Pickup Zones
- Top Drop-off Zones
- Demand Distribution
- Hourly Trip Trend

### 📍 3. Trip & Location Analysis

Analyzes geographic and trip-level behavior.

Includes:

- Pickup Zone Analysis
- Drop-off Zone Analysis
- Average Trip Distance
- Trip Duration
- Passenger Distribution

### 💰 4. Revenue Analysis

Focuses on revenue and fare behavior.

Includes:

- Revenue Trend
- Fare Distribution
- Average Fare
- Tip Analysis
- Payment Method Analysis

---

# 📸 Dashboard Preview

Add your Power BI dashboard screenshots inside the `images` folder.

### 🏠 Overview Dashboard

![Overview Dashboard](images/overview.png)

### 🚕 Demand Analysis

![Demand Analysis](images/demand_analysis.png)

### 📍 Trip & Location Analysis

![Trip & Location Analysis](images/trip_analysis.png)

### 💰 Revenue Analysis

![Revenue Analysis](images/revenue_analysis.png)

---

# 🔍 Sample Business Questions

The project answers questions such as:

1. What is the total number of taxi trips?
2. What is the average trip distance?
3. Which hour has the highest taxi demand?
4. Which pickup zone has the highest number of trips?
5. Which drop-off zone is most frequently used?
6. What is the average fare per trip?
7. Which payment method is most commonly used?
8. What is the relationship between trip distance and fare?
9. How does taxi demand vary throughout the day?
10. Which locations generate the highest taxi activity?

---

# 📐 Example DAX Measures

### Total Trips

```DAX
Total Trips =
COUNTROWS('NYC_Clean')
```

### Average Trip Distance

```DAX
Avg Trip Distance =
AVERAGE('NYC_Clean'[trip_distance])
```

### Average Fare

```DAX
Avg Fare =
AVERAGE('NYC_Clean'[fare_amount])
```

### Total Revenue

```DAX
Total Revenue =
SUM('NYC_Clean'[total_amount])
```

---

# 📊 Data Analysis

Python and SQL were used to investigate:

- Data distributions
- Missing values
- Outliers
- Trip patterns
- Revenue patterns
- Distance patterns
- Passenger behavior
- Location-level demand
- Time-based demand

The cleaned dataset was then used to build the Power BI semantic model and interactive dashboards.

---

# 💡 Key Insights

The analysis helps identify:

- Peak taxi demand periods
- High-traffic pickup locations
- High-frequency drop-off locations
- Typical trip distances
- Revenue patterns
- Payment preferences
- Relationship between distance and fare
- Operational demand patterns

> **Note:** Final quantified insights will be added after completing the final dashboard analysis.

---

# 📁 Project Structure

```text
NYC-Taxi-Data-Analysis/
│
├── 📂 data/
│   ├── NYC_Clean.csv
│   └── README.md
│
├── 📂 python/
│   └── NYC_Taxi_Analysis.ipynb
│
├── 📂 sql/
│   └── NYC_Taxi_Analysis.sql
│
├── 📂 powerbi/
│   └── NYC_Taxi_Dashboard.pbix
│
├── 📂 images/
│   ├── overview.png
│   ├── demand_analysis.png
│   ├── trip_analysis.png
│   └── revenue_analysis.png
│
├── 📄 README.md
└── 📄 .gitignore
```

> **Note:** The raw NYC Taxi dataset is large, so it should be managed using **Git LFS** or hosted externally rather than committed through normal Git.

---

# 🚀 Skills Demonstrated

This project demonstrates practical experience in:

- Data Cleaning
- Data Preprocessing
- Exploratory Data Analysis
- SQL Querying
- Data Transformation
- Data Modeling
- DAX
- KPI Development
- Dashboard Design
- Business Analysis
- Data Visualization
- Insight Generation
- Git & GitHub

---

# 📌 Project Highlights

✅ End-to-end Data Analytics workflow  
✅ Real-world taxi trip dataset  
✅ Python-based data cleaning & EDA  
✅ SQL-based business analysis  
✅ Power Query transformations  
✅ DAX measures and calculated metrics  
✅ Interactive Power BI dashboard  
✅ Time-based demand analysis  
✅ Location-based analysis  
✅ Revenue & fare analysis  

---

# 👨‍💻 Author

### **Gyanendra Singh**

**Data Analyst | Python | SQL | Power BI | Excel**

📌 GitHub: [github.com/pslvgyanendra](https://github.com/pslvgyanendra)

---

## ⭐ If You Find This Project Useful

If you find this project helpful or interesting, consider giving the repository a ⭐ **Star**.

---

### 📜 Disclaimer

This project is created for **educational and portfolio purposes**. The analysis and insights are based on the available dataset and should not be interpreted as official NYC transportation statistics.
