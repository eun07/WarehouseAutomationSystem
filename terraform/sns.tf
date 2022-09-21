resource "aws_sns_topic" "stock_update" {
  name            = "stock-updates-topic"
  delivery_policy = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false,
    "defaultThrottlePolicy": {
      "maxReceivesPerSecond": 1
    }
  }
}
EOF

tags ={
    Name="stock-queue"
}
}
# module "stockQueue" {
#   source  = "terraform-aws-modules/sqs/aws"
#   version = "~> 2.0"

#   name = "user"

#     tags ={
#         Name = "stock-queue"
#     }
# }
resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.stock_update.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.terraform_queue.arn
}