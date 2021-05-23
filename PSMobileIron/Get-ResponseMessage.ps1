function Get-ResponseMessage ($code) {
    switch ($code) {
        200 {
            return "OK: Success"
        }
        400 {
            return "Bad request: The request was invalid. The accompanying error message in the output explains the reason."
        }
        401 {
            return "Unauthorized: Authentication to the API has failed. Authentication credentials are missing or wrong."
        }
        404 {
            return "Not found: The requested resource is not found. The accompanying error message explains the reason."
        }
        405 {
            return "Method Not Allowed:  The HTTP request method that was specified is not the correct method for the request."
        }
        500 {
            return " Internal Server Error: An internal server error has occurred while processing the request."
        }
        502 {
            return "Bad Gateway: The MobileIron server is not reachable."
        }
    }
}