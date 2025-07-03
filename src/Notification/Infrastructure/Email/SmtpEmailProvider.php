<?php

declare(strict_types=1);

namespace Notification\Infrastructure\Email;

interface SmtpEmailProvider
{
    /**
     * Send email via SMTP
     * 
     * @param string $to Recipient email address
     * @param string $subject Email subject
     * @param string $htmlContent HTML content of the email
     * @param array<string, string> $headers Additional headers
     * 
     * @throws \RuntimeException if sending fails
     */
    public function send(string $to, string $subject, string $htmlContent, array $headers = []): void;
} 