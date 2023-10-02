resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = "carbon"
  description = "Shall handle all functions of my calcultor"
}

resource "aws_api_gateway_deployment" "api_deployments" {
  depends_on      = [
    aws_api_gateway_integration.post_integration,
    aws_api_gateway_integration.get_progress_inte,
    aws_api_gateway_integration.store_data_inte,
    aws_api_gateway_integration.table_integration
  ]
  rest_api_id      = aws_api_gateway_rest_api.api_gateway.id
  stage_name       = "dev"
}

# Calculates the carbon emission for all vehicles
resource "aws_lambda_function" "calculate_emsission" {
  function_name = "my-post-function"
  handler      = "calcuate_emission.lambda_handler"  # e.g., "app.lambda_handler"
  runtime      = "python3.8"  # Use the appropriate runtime
  filename     = "calcuate_emission.zip"
  source_code_hash = filebase64sha256("calcuate_emission.zip")
  role         = aws_iam_role.lambda_exec_role.arn
  # timeout      = 60  # Set an appropriate timeout value
  memory_size  = 512  # Set an appropriate memory size
  environment {
      variables = {
        DB_NAME       = var.database_name,
        DB_USER       = var.master_username,
        DB_PASSWORD   = var.master_password,
        DB_HOST       = aws_rds_cluster.aurora_postgresql.endpoint,
      }
    }
  vpc_config {
    subnet_ids         = [aws_subnet.private_subnet2.id,aws_subnet.private_subnet.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

}

resource "aws_api_gateway_resource" "post_resource" {
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "calculations"
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
}

resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.post_resource.id
  http_method   = "POST" 
  authorization = "NONE"
 
}

resource "aws_api_gateway_integration" "post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.post_resource.id
  http_method             = aws_api_gateway_method.post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.calculate_emsission.invoke_arn
}

resource "aws_lambda_permission" "post_permisiion" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.calculate_emsission.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:ap-southeast-1:435495016122:${aws_api_gateway_rest_api.api_gateway.id}/*/POST${aws_api_gateway_resource.post_resource.path}"
}

# Calculates the persons progress
resource "aws_lambda_function" "get_progress" {
  function_name = "get-progress"
  handler      = "get_progress.get_progress_handler"  # Update the handler for your GET request function
  runtime      = "python3.8"  # Use the appropriate runtime
  filename     = "get_progress.zip"
  source_code_hash = filebase64sha256("get_progress.zip")
  role         = aws_iam_role.lambda_exec_role.arn

  environment {
      variables = {
        DB_NAME       = var.database_name,
        DB_USER       = var.master_username,
        DB_PASSWORD   = var.master_password,
        DB_HOST       = aws_rds_cluster.aurora_postgresql.endpoint,
      }
  }
  
  vpc_config {
    subnet_ids         = [aws_subnet.private_subnet2.id, aws_subnet.private_subnet.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  depends_on = [aws_rds_cluster_instance.aurora_postgresql_instance]
}

resource "aws_api_gateway_resource" "get_progress_api_gw" {
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  path_part   = "progress"
}

resource "aws_api_gateway_method" "get_progress_method" {
  resource_id   = aws_api_gateway_resource.get_progress_api_gw.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_progress_inte" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.get_progress_api_gw.id
  http_method             = aws_api_gateway_method.get_progress_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_progress.invoke_arn
}

resource "aws_lambda_permission" "get_progress_permisison" {
  statement_id  = "AllowAPIGatewayInvokeGetProgress"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_progress.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:ap-southeast-1:435495016122:${aws_api_gateway_rest_api.api_gateway.id}/*/GET${aws_api_gateway_resource.get_progress_api_gw.path}"
}

# Calculates the stores person progress
resource "aws_lambda_function" "store_data" {
  function_name = "store-data"
  handler      = "store_data.store_data_handler" 
  runtime      = "python3.8" 
  filename     = "store_data.zip"
  source_code_hash = filebase64sha256("store_data.zip")
  role         = aws_iam_role.lambda_exec_role.arn

  environment {
      variables = {
        DB_NAME       = var.database_name,
        DB_USER       = var.master_username,
        DB_PASSWORD   = var.master_password,
        DB_HOST       = aws_rds_cluster.aurora_postgresql.endpoint,
      }
    }
  vpc_config {
    subnet_ids         = [aws_subnet.private_subnet2.id, aws_subnet.private_subnet.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  depends_on = [aws_rds_cluster_instance.aurora_postgresql_instance]
}

resource "aws_api_gateway_resource" "store_data_api_gw" {
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "store"  
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
}

resource "aws_api_gateway_method" "store_data_method" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.store_data_api_gw.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "store_data_inte" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.store_data_api_gw.id
  http_method             = aws_api_gateway_method.store_data_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.store_data.invoke_arn
}

resource "aws_lambda_permission" "store_data_permissison" {
  statement_id  = "AllowAPIGatewayInvokeStoreData"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.store_data.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:ap-southeast-1:435495016122:${aws_api_gateway_rest_api.api_gateway.id}/*/POST${aws_api_gateway_resource.store_data_api_gw.path}"
}

# Create tables
resource "aws_lambda_function" "tables" {
  function_name = "createtables"
  handler      = "create_tables.lambda_handler"  
  runtime      = "python3.8" 
  filename     = "create_tables.zip"
  source_code_hash = filebase64sha256("create_tables.zip")
  role         = aws_iam_role.lambda_exec_role.arn

  environment {
      variables = {
        DB_NAME       = var.database_name,
        DB_USER       = var.master_username,
        DB_PASSWORD   = var.master_password,
        DB_HOST       = aws_rds_cluster.aurora_postgresql.endpoint,
      }
    }
  vpc_config {
    subnet_ids         = [aws_subnet.private_subnet2.id,aws_subnet.private_subnet.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  depends_on = [aws_rds_cluster_instance.aurora_postgresql_instance]
}

resource "aws_api_gateway_resource" "table_resource" {
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "tables"
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
}

resource "aws_api_gateway_method" "table_method" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.table_resource.id
  http_method   = "GET" 
  authorization = "NONE"
 
}

resource "aws_api_gateway_integration" "table_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.table_resource.id
  http_method             = aws_api_gateway_method.table_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.tables.invoke_arn
}

resource "aws_lambda_permission" "table_permisiion" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tables.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:ap-southeast-1:435495016122:${aws_api_gateway_rest_api.api_gateway.id}/*/GET${aws_api_gateway_resource.table_resource.path}"
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name = "/aws/lambda/${aws_lambda_function.calculate_emsission.function_name}"
  retention_in_days = 30  # Adjust as needed
}