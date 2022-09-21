

resource "aws_sqs_queue" "terraform_queue" {
  name                        = "terraform-example-queue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.terraform_queue_deadletter.arn
    maxReceiveCount     = 4
  })

}

#DLQ
resource "aws_sqs_queue" "terraform_queue_deadletter" {
  name = "terraform-example-deadletter-queue"

}