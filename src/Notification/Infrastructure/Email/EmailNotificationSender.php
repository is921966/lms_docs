<?php

declare(strict_types=1);

namespace Notification\Infrastructure\Email;

use Notification\Application\Services\TemplateRenderer;
use Notification\Domain\Notification;
use Notification\Domain\ValueObjects\NotificationChannel;
use Notification\Domain\ValueObjects\NotificationPriority;

class EmailNotificationSender
{
    public function __construct(
        private SmtpEmailProvider $emailProvider,
        private TemplateRenderer $templateRenderer
    ) {
    }
    
    public function send(Notification $notification): void
    {
        if (!$this->supports($notification)) {
            throw new \InvalidArgumentException('EmailNotificationSender only supports email notifications');
        }
        
        try {
            $htmlContent = $this->templateRenderer->render(
                $this->getTemplateName($notification),
                $this->getTemplateData($notification)
            );
        } catch (\RuntimeException $e) {
            throw new \RuntimeException('Failed to render email template: ' . $e->getMessage(), 0, $e);
        }
        
        $headers = [];
        if ($notification->isHighPriority()) {
            $headers['X-Priority'] = '1';
            $headers['Importance'] = 'high';
        }
        
        try {
            $this->emailProvider->send(
                $notification->getRecipientId()->getValue(), // In real implementation, would resolve to email
                $notification->getSubject(),
                $htmlContent,
                $headers
            );
        } catch (\RuntimeException $e) {
            throw new \RuntimeException('Failed to send email: ' . $e->getMessage(), 0, $e);
        }
    }
    
    public function supports(Notification $notification): bool
    {
        return $notification->getChannel()->equals(NotificationChannel::email());
    }
    
    private function getTemplateName(Notification $notification): string
    {
        return sprintf(
            'email/%s',
            $notification->getType()->getValue()
        );
    }
    
    private function getTemplateData(Notification $notification): array
    {
        return [
            'subject' => $notification->getSubject(),
            'content' => $notification->getContent(),
            'metadata' => $notification->getMetadata(),
            'recipientId' => $notification->getRecipientId()->getValue(),
        ];
    }
} 