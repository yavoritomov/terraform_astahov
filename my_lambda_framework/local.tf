locals {
 lambdas = {
   "script-0" = { lambda = {memory_size = "128M", description="description for 0", timeout = 30, runtime = "python3.8"}, cloudwatch ={retention_in_days = 14}, eventbridge ={enabled = true, schedule = "rate(1 minute)", description="description for 0"}},
   "script-1" = { lambda = {memory_size = "128M", description="description for 1", timeout = 30, runtime = "python3.8"}, cloudwatch ={retention_in_days = 14}, eventbridge ={enabled = false, schedule = "rate(5 minutes)", description="description for 1"}},
   "script-2" = { lambda = {memory_size = "128M", description="description for 2", timeout = 30, runtime = "python3.8"}, cloudwatch ={retention_in_days = 14}, eventbridge ={enabled = true, schedule = "rate(3 minutes)", description="description for 2"}},
 }
  lambda_function_url = {
    "script-2" = {"authorization_type" = "NONE"}
  }
}