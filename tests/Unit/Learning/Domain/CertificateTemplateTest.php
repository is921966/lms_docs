<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Domain;

use Learning\Domain\CertificateTemplate;
use Learning\Domain\ValueObjects\CertificateId;
use PHPUnit\Framework\TestCase;

class CertificateTemplateTest extends TestCase
{
    public function testCanBeCreated(): void
    {
        $template = CertificateTemplate::create(
            name: 'Default Certificate',
            description: 'Standard certificate template',
            templatePath: 'templates/certificates/default.html',
            variables: ['courseName', 'userName', 'completionDate', 'score']
        );
        
        $this->assertInstanceOf(CertificateTemplate::class, $template);
        $this->assertInstanceOf(CertificateId::class, $template->getId());
        $this->assertEquals('Default Certificate', $template->getName());
        $this->assertEquals('Standard certificate template', $template->getDescription());
        $this->assertEquals('templates/certificates/default.html', $template->getTemplatePath());
        $this->assertContains('courseName', $template->getVariables());
        $this->assertTrue($template->isActive());
    }
    
    public function testCanUpdateBasicInfo(): void
    {
        $template = $this->createTestTemplate();
        
        $template->updateBasicInfo(
            name: 'Premium Certificate',
            description: 'Premium template with enhanced design',
            templatePath: 'templates/certificates/premium.html'
        );
        
        $this->assertEquals('Premium Certificate', $template->getName());
        $this->assertEquals('Premium template with enhanced design', $template->getDescription());
        $this->assertEquals('templates/certificates/premium.html', $template->getTemplatePath());
    }
    
    public function testCanManageVariables(): void
    {
        $template = $this->createTestTemplate();
        $this->assertCount(2, $template->getVariables());
        
        $template->addVariable('instructorName');
        $this->assertContains('instructorName', $template->getVariables());
        $this->assertCount(3, $template->getVariables());
        
        $template->removeVariable('userName');
        $this->assertNotContains('userName', $template->getVariables());
        $this->assertCount(2, $template->getVariables());
    }
    
    public function testCannotAddDuplicateVariable(): void
    {
        $template = $this->createTestTemplate();
        
        $template->addVariable('newVariable');
        $template->addVariable('newVariable'); // Should be ignored
        
        $variables = $template->getVariables();
        $this->assertEquals(1, array_count_values($variables)['newVariable']);
    }
    
    public function testCanSetStyles(): void
    {
        $template = $this->createTestTemplate();
        
        $styles = [
            'backgroundColor' => '#ffffff',
            'primaryColor' => '#007bff',
            'fontFamily' => 'Arial, sans-serif',
            'fontSize' => '14px'
        ];
        
        $template->setStyles($styles);
        
        $this->assertEquals($styles, $template->getStyles());
    }
    
    public function testCanSetSettings(): void
    {
        $template = $this->createTestTemplate();
        
        $settings = [
            'paperSize' => 'A4',
            'orientation' => 'landscape',
            'margin' => '2cm',
            'includeQrCode' => true
        ];
        
        $template->setSettings($settings);
        
        $this->assertEquals($settings, $template->getSettings());
    }
    
    public function testCanBeActivatedAndDeactivated(): void
    {
        $template = $this->createTestTemplate();
        $this->assertTrue($template->isActive());
        
        $template->deactivate();
        $this->assertFalse($template->isActive());
        
        $template->activate();
        $this->assertTrue($template->isActive());
    }
    
    public function testCanSetAsDefault(): void
    {
        $template = $this->createTestTemplate();
        $this->assertFalse($template->isDefault());
        
        $template->setAsDefault();
        $this->assertTrue($template->isDefault());
        
        $template->unsetDefault();
        $this->assertFalse($template->isDefault());
    }
    
    public function testCanValidateVariables(): void
    {
        $template = $this->createTestTemplate();
        $template->addVariable('score');
        
        $validData = [
            'courseName' => 'PHP Course',
            'userName' => 'John Doe',
            'score' => 95
        ];
        
        $this->assertTrue($template->validateVariables($validData));
        
        $invalidData = [
            'courseName' => 'PHP Course'
            // Missing required variables
        ];
        
        $this->assertFalse($template->validateVariables($invalidData));
    }
    
    private function createTestTemplate(): CertificateTemplate
    {
        return CertificateTemplate::create(
            name: 'Test Template',
            description: 'Test Description',
            templatePath: 'test/path.html',
            variables: ['courseName', 'userName']
        );
    }
} 