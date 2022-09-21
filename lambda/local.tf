locals {
 lambdas = {
   "script-0" = { memory_size = "128M", schedule = "us-central1-a", description="description for 0" },
   "script-1" = { memory_size = "128M", schedule = "us-central1-b", description="description for 1" },
   "script-2" = { memory_size = "128M", schedule = "us-central1-c", description="description for 2" }
 }
}