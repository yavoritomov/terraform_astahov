locals {
 lambdas = {
   "script-0" = { memory_size = "128M", schedule = "rate(1 minute)", description="description for 0", description_eventbridge="description for 0" },
   "script-1" = { memory_size = "128M", schedule = "rate(5 minutes)", description="description for 1", description_eventbridge="description for 1" },
   "script-2" = { memory_size = "128M", schedule = "rate(1 hour)", description="description for 2", description_eventbridge="description for 2" }
 }
}