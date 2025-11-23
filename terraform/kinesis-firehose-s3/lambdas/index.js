exports.handler = async (event, context) => {
    // Function to convert Celsius to Fahrenheit
    const celsiusToFahrenheit = (celsius) => (celsius * 9) / 5 + 32;
  
    // Filter and transform the incoming records
    const output = event.records.map((record) => {
      // Decode base64 encoded record data
      const payload = Buffer.from(record.data, 'base64').toString('ascii');
      let data = JSON.parse(payload);
  
      // Check and filter data based on humidity (for example, filter out humidity > 90%)
      if (data.humidity <= 90) {
        // Convert temperature to Fahrenheit and add processing timestamp
        data.temperature = celsiusToFahrenheit(data.temperature);
        data.processedAt = new Date().toISOString();
  
        // Re-encode the transformed data to base64
        const outputPayload = Buffer.from(JSON.stringify(data)).toString('base64');
        return {
          recordId: record.recordId,
          result: 'Ok',
          data: outputPayload,
        };
      } else {
        // Skip this record by marking it as 'Dropped'
        return {
          recordId: record.recordId,
          result: 'Dropped',
          data: record.data, // Original data in case it needs to be inspected later
        };
      }
    });
  
    console.log(`Processed ${output.length} records.`);
    return { records: output };
  };
  