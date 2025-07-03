<?php

declare(strict_types=1);

namespace Tests\Unit\Notification\Infrastructure\Email;

use PHPUnit\Framework\TestCase;
use Notification\Infrastructure\Email\EmailNotificationSender;
use Notification\Infrastructure\Email\SmtpEmailProvider;
use Notification\Application\Services\TemplateRenderer;
use Notification\Domain\Notification;
use Notification\Domain\ValueObjects\NotificationId;
use Notification\Domain\ValueObjects\NotificationType;
use Notification\Domain\ValueObjects\NotificationChannel;
use Notification\Domain\ValueObjects\NotificationPriority;
use Notification\Domain\ValueObjects\RecipientId;

class EmailNotificationSenderTest extends TestCase
{
    private SmtpEmailProvider $emailProvider;
    private TemplateRenderer $templateRenderer;
    private EmailNotificationSender $sender;
    
    protected function setUp(): void
    {
        $this->emailProvider = $this->createMock(SmtpEmailProvider::class);
        $this->templateRenderer = $this->createMock(TemplateRenderer::class);
        $this->sender = new EmailNotificationSender($this->emailProvider, $this->templateRenderer);
    }
    
    public function testSendEmailNotification(): void
    {
        $notification = $this->createEmailNotification();
        
        $this->templateRenderer->expects($this->once())
            ->method('render')
            ->with(
                'email/course_assigned',
                [
                    'subject' => 'Course Assignment',
                    'content' => 'You have been assigned to a new course',
                    'metadata' => ['courseName' => 'PHP Advanced'],
                    'recipientId' => 'f47ac10b-58cc-4372-a567-0e02b2c3d479'
                ]
            )
            ->willReturn('<html><body>Rendered email content</body></html>');
            
        $this->emailProvider->expects($this->once())
            ->method('send')
            ->with(
                'f47ac10b-58cc-4372-a567-0e02b2c3d479', // recipient email (would be resolved in real implementation)
                'Course Assignment',
                '<html><body>Rendered email content</body></html>',
                []
            );
        
        $this->sender->send($notification);
    }
    
    public function testSendWithHighPrioritySetsPriorityHeader(): void
    {
        $notification = Notification::create(
            NotificationId::generate(),
            RecipientId::fromString('f47ac10b-58cc-4372-a567-0e02b2c3d479'),
            NotificationType::systemAnnouncement(),
            NotificationChannel::email(),
            'Urgent System Maintenance',
            'System will be down for maintenance',
            NotificationPriority::high()
        );
        
        $this->templateRenderer->expects($this->once())
            ->method('render')
            ->willReturn('<html><body>Urgent message</body></html>');
            
        $this->emailProvider->expects($this->once())
            ->method('send')
            ->with(
                $this->anything(),
                $this->anything(),
                $this->anything(),
                ['X-Priority' => '1', 'Importance' => 'high']
            );
        
        $this->sender->send($notification);
    }
    
    public function testSupportsOnlyEmailChannel(): void
    {
        $emailNotification = $this->createEmailNotification();
        $pushNotification = Notification::create(
            NotificationId::generate(),
            RecipientId::fromString('f47ac10b-58cc-4372-a567-0e02b2c3d479'),
            NotificationType::courseAssigned(),
            NotificationChannel::push(),
            'Push Subject',
            'Push Content',
            NotificationPriority::medium()
        );
        
        $this->assertTrue($this->sender->supports($emailNotification));
        $this->assertFalse($this->sender->supports($pushNotification));
    }
    
    public function testThrowsExceptionForNonEmailNotification(): void
    {
        $pushNotification = Notification::create(
            NotificationId::generate(),
            RecipientId::fromString('f47ac10b-58cc-4372-a567-0e02b2c3d479'),
            NotificationType::courseAssigned(),
            NotificationChannel::push(),
            'Push Subject',
            'Push Content',
            NotificationPriority::medium()
        );
        
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('EmailNotificationSender only supports email notifications');
        
        $this->sender->send($pushNotification);
    }
    
    public function testHandlesTemplateRenderingException(): void
    {
        $notification = $this->createEmailNotification();
        
        $this->templateRenderer->expects($this->once())
            ->method('render')
            ->willThrowException(new \RuntimeException('Template not found'));
            
        $this->expectException(\RuntimeException::class);
        $this->expectExceptionMessage('Failed to render email template: Template not found');
        
        $this->sender->send($notification);
    }
    
    public function testHandlesEmailProviderException(): void
    {
        $notification = $this->createEmailNotification();
        
        $this->templateRenderer->expects($this->once())
            ->method('render')
            ->willReturn('<html><body>Content</body></html>');
            
        $this->emailProvider->expects($this->once())
            ->method('send')
            ->willThrowException(new \RuntimeException('SMTP connection failed'));
            
        $this->expectException(\RuntimeException::class);
        $this->expectExceptionMessage('Failed to send email: SMTP connection failed');
        
        $this->sender->send($notification);
    }
    
    private function createEmailNotification(): Notification
    {
        return Notification::create(
            NotificationId::generate(),
            RecipientId::fromString('f47ac10b-58cc-4372-a567-0e02b2c3d479'),
            NotificationType::courseAssigned(),
            NotificationChannel::email(),
            'Course Assignment',
            'You have been assigned to a new course',
            NotificationPriority::medium(),
            ['courseName' => 'PHP Advanced']
        );
    }
} 