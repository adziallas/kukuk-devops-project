package com.kukuk.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class WelcomeController {

    @GetMapping("/")
    public String welcome() {
        return "Willkommen dein kukuk-backend läuft";
    }

    @GetMapping("/health")
    public String health() {
        return "Backend is healthy";
    }

    @GetMapping("/api/welcome")
    public String apiWelcome() {
        return "Willkommen dein kukuk-backend läuft - API Endpoint";
    }
}
