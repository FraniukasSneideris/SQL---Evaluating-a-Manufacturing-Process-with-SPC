# SQL--Evaluating-a-Manufacturing-Process-with-SPC
Evaluating a Manufacturing Process with Statistical Process Control

## Overview

This project implements Statistical Process Control (SPC) to monitor and control the manufacturing process. The goal is to ensure that the height of manufactured parts remains within acceptable control limits, making adjustments only when measurements fall outside these limits. The analysis is done using SQL queries that calculate the **Upper Control Limit (UCL)** and **Lower Control Limit (LCL)** for part heights.

## Key Concepts

- **Upper Control Limit (UCL):** The maximum acceptable height for a part.
- **Lower Control Limit (LCL):** The minimum acceptable height for a part.
- **Statistical Process Control (SPC):** A method for monitoring the quality of a manufacturing process using statistical methods.

## Data

The project analyzes data from the `manufacturing_parts` table, which contains the following fields:

- `item_no`: The item number.
- `length`: The length of the manufactured part.
- `width`: The width of the manufactured part.
- `height`: The height of the manufactured part.
- `operator`: The machine/operator producing the part.

## Approach

The primary goal is to determine whether each part produced by an operator falls within acceptable height limits by calculating control limits:

- **UCL = avg_height + 3 * stddev_height / sqrt(5)**
- **LCL = avg_height - 3 * stddev_height / sqrt(5)**

Where:  
- `avg_height` is the average height of the last 5 parts for each operator.  
- `stddev_height` is the standard deviation of the heights for the same last 5 parts.  

The logic evaluates whether each part height falls outside these control limits. If the height exceeds the UCL or is below the LCL, an alert is generated. A **False** alert indicates the part is within limits, which is favorable since it confirms compliance with control boundaries. Conversely, a **True** alert signals a potential issue with the part's height.


### SQL Query 

The SQL query calculates the control limits and flags whether the height of each part is within the acceptable range:

```sql
SELECT fin.*,
       CASE
           WHEN fin.height NOT BETWEEN fin.lcl AND fin.ucl
           THEN TRUE
           ELSE FALSE
       END AS alert
FROM (SELECT agg.*,
             agg.avg_height + 3*agg.stddev_height/SQRT(5) AS ucl,
             agg.avg_height - 3*agg.stddev_height/SQRT(5) AS lcl
      FROM (SELECT operator,
                   ROW_NUMBER() OVER wind AS row_number,
                   height,
                   AVG(height) OVER wind AS avg_height,
                   STDDEV(height) OVER wind AS stddev_height
            FROM manufacturing_parts
            WINDOW wind AS (PARTITION BY operator
                            ORDER BY item_no
                            ROWS BETWEEN 4 PRECEDING AND CURRENT ROW)) AS agg
     WHERE agg.row_number >= 5) AS fin;
```

## Fields in the Query Result

The final query returns the following fields:

- **operator**: The machine/operator producing the part.
- **row_number**: The row number in the result set.
- **height**: The height of the manufactured part.
- **avg_height**: The average height of the last 5 parts for the operator.
- **stddev_height**: The standard deviation of the heights for the last 5 parts.
- **ucl**: The upper control limit for the part height.
- **lcl**: The lower control limit for the part height.
- **alert**: A boolean flag indicating whether the height of the part is outside the control limits, ideally the alert should be FALSE, indicating that the part is within limits.

### Results

## Graphical Representation: Average Height by Operator with Alert included
![image](https://github.com/user-attachments/assets/128229b8-3d70-4feb-a75e-6896dd15b033)


### Conclusion

Based on the analysis of the manufacturing process, the majority of operators are performing within the expected range, with only a few instances where part heights fall outside the control limits. This indicates that the process is largely stable, though occasional adjustments may still be necessary to maintain optimal quality.

