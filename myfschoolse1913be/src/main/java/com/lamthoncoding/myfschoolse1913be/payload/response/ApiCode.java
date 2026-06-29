package com.lamthoncoding.myfschoolse1913be.payload.response;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum ApiCode {
    SUCCESS("S001", "Success"),
    CREATED("S002", "Created"),
    BAD_REQUEST("E001", "Bad Request"),
    NOT_FOUND("E002", "Entity Not Found"),
    CONFLICT("E003", "Conflict"),
    INTERNAL_ERROR("E004", "Internal Error"),
    UNAUTHORIZED("E005", "Unauthorized"),
    VALIDATION_ERROR("E006", "Validation Error"),
    UNAUTHORIZED_USER("E007", "Invalid username or password"),
    APPLICATION_NOT_FOUND("E008", "Application not found"),
    NOTIFICATION_NOT_FOUND("E009", "Notification not found"),
    ACCESS_DENIED("E010", "Access denied"),
    APPLICATION_ALREADY_REVIEWED("E011", "Application has already been reviewed"),;

    private final String code;
    private final String message;

}

