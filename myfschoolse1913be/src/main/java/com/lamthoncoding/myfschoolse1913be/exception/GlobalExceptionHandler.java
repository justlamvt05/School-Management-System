package com.lamthoncoding.myfschoolse1913be.exception;


import com.lamthoncoding.myfschoolse1913be.exception.handlers.AccessDeniedException;
import com.lamthoncoding.myfschoolse1913be.exception.handlers.ApplicationAlreadyReviewedException;
import com.lamthoncoding.myfschoolse1913be.exception.handlers.EntityNotFound;
import com.lamthoncoding.myfschoolse1913be.exception.handlers.InvalidInputException;
import com.lamthoncoding.myfschoolse1913be.exception.handlers.UnauthorizedException;
import com.lamthoncoding.myfschoolse1913be.payload.response.ApiCode;
import com.lamthoncoding.myfschoolse1913be.payload.response.ApiResponse;
import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.multipart.MaxUploadSizeExceededException;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, Object>> handleException( Exception ex, HttpServletRequest request) {

        Map<String, Object> body = new HashMap<>();
        body.put("status", 500);
        body.put("code", "E500");
        body.put("error", "Internal Server Error");
        body.put("message", ex.getMessage());
        body.put("path", request.getServletPath());
        body.put("timestamp", LocalDateTime.now());

        return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .contentType(MediaType.APPLICATION_JSON)
                .body(body);
    }


    @ExceptionHandler(EntityNotFound.class)
    public ResponseEntity<ApiResponse<?>> handleEntityNotFound(EntityNotFound e) {
        String message = e.getMessage();
        if (message == null) {
            message = "Entity not found";
        }
        log.error(message);
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(ApiCode.NOT_FOUND, message));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResponse<?>> handleMethodArgumentNotValid(MethodArgumentNotValidException e) {

        List<String> errors = e.getBindingResult()
                .getFieldErrors()
                .stream()
                .map(error -> error.getField() + ": " + error.getDefaultMessage())
                .toList();

        log.error(errors.toString());

        return ResponseEntity.badRequest()
                .body(ApiResponse.error(ApiCode.VALIDATION_ERROR, errors));
    }

    @ExceptionHandler(UnauthorizedException.class)
    public ResponseEntity<ApiResponse<?>> handleUnauthorized(UnauthorizedException e) {
        String message = e.getMessage();
        log.error(message);
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(ApiResponse.error(ApiCode.UNAUTHORIZED, message));
    }

    @ExceptionHandler(InvalidInputException.class)
    public ResponseEntity<ApiResponse<?>> handleInvalidInput(InvalidInputException e) {
        String message = e.getMessage();
        log.error(message);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(ApiResponse.error(ApiCode.BAD_REQUEST, message));
    }

    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<ApiResponse<?>> handleAccessDenied(AccessDeniedException e) {
        String message = e.getMessage();
        log.error(message);
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(ApiResponse.error(ApiCode.ACCESS_DENIED, message));
    }

    @ExceptionHandler(ApplicationAlreadyReviewedException.class)
    public ResponseEntity<ApiResponse<?>> handleApplicationAlreadyReviewed(ApplicationAlreadyReviewedException e) {
        String message = e.getMessage();
        log.error(message);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(ApiResponse.error(ApiCode.APPLICATION_ALREADY_REVIEWED, message));
    }

    @ExceptionHandler(MaxUploadSizeExceededException.class)
    public ResponseEntity<ApiResponse<?>> handleMaxSizeException() {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(ApiResponse.error(ApiCode.CONFLICT, "File too big"));
    }
}

