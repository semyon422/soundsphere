# ModifiedChartHeader
- chart hash
- chart index
- inputmode: string
- modifiers: table
- data_hash

# Replay
- ModifiedChartHeader

- rate
- const
- timings
- single

- rate_type
- player
- timestamp
- pauses_count
- online_user_id

- data_compressed
- size_uncompressed

# ModifiedChart
- ModifiedChartHeader
- data_compressed
- size_uncompressed

# ReplayBundle
- ModifiedChartHeader
- Replay - ModifiedChartHeader
- ModifiedChart - ModifiedChartHeader
