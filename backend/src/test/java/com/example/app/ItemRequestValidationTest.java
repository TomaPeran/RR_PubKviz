package com.example.app;

import com.example.app.item.ItemController.CreateItemRequest;
import jakarta.validation.Validation;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class ItemRequestValidationTest {

    private final jakarta.validation.Validator validator = Validation.buildDefaultValidatorFactory().getValidator();

    @Test
    void blankNameIsRejected() {
        assertFalse(validator.validate(new CreateItemRequest(" ")).isEmpty());
    }

    @Test
    void validNameIsAccepted() {
        assertTrue(validator.validate(new CreateItemRequest("test")).isEmpty());
    }
}
