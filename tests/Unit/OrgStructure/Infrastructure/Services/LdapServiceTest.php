<?php

namespace Tests\Unit\OrgStructure\Infrastructure\Services;

use PHPUnit\Framework\TestCase;
use App\OrgStructure\Infrastructure\Services\LdapService;
use App\OrgStructure\Domain\ValueObjects\TabNumber;
use App\OrgStructure\Infrastructure\DTO\LdapUserData;

class LdapServiceTest extends TestCase
{
    private LdapService $service;
    private $ldapConnection;
    
    protected function setUp(): void
    {
        // Мокаем LDAP соединение
        $this->ldapConnection = $this->getMockBuilder('stdClass')
            ->addMethods(['bind', 'search', 'get_entries', 'unbind'])
            ->getMock();
            
        $this->service = new LdapService($this->ldapConnection);
    }
    
    public function testFindUserByTabNumberReturnsNull(): void
    {
        // Arrange
        $tabNumber = new TabNumber('EMP001');
        
        $this->ldapConnection->expects($this->once())
            ->method('search')
            ->willReturn(false);
        
        // Act
        $result = $this->service->findUserByTabNumber($tabNumber);
        
        // Assert
        $this->assertNull($result);
    }
    
    public function testFindUserByTabNumberReturnsUserData(): void
    {
        // Arrange
        $tabNumber = new TabNumber('EMP001');
        
        $searchResult = 'search_result';
        $entries = [
            'count' => 1,
            0 => [
                'cn' => ['John Doe'],
                'mail' => ['john.doe@example.com'],
                'telephonenumber' => ['+7 123 456 78 90'],
                'department' => ['IT Department'],
                'title' => ['Software Developer'],
                'manager' => ['CN=Jane Manager,OU=Users,DC=example,DC=com'],
                'distinguishedname' => ['CN=John Doe,OU=Users,DC=example,DC=com']
            ]
        ];
        
        $this->ldapConnection->expects($this->once())
            ->method('search')
            ->willReturn($searchResult);
            
        $this->ldapConnection->expects($this->once())
            ->method('get_entries')
            ->with($searchResult)
            ->willReturn($entries);
        
        // Act
        $result = $this->service->findUserByTabNumber($tabNumber);
        
        // Assert
        $this->assertNotNull($result);
        $this->assertInstanceOf(LdapUserData::class, $result);
        $this->assertEquals('John Doe', $result->getFullName());
        $this->assertEquals('john.doe@example.com', $result->getEmail());
    }
    
    public function testSyncEmployeeWithLdap(): void
    {
        // Arrange
        $tabNumber = new TabNumber('EMP001');
        $searchResult = 'search_result';
        $entries = [
            'count' => 1,
            0 => [
                'cn' => ['John Doe'],
                'mail' => ['john.doe@example.com'],
                'telephonenumber' => ['+7 123 456 78 90'],
                'distinguishedname' => ['CN=John Doe,OU=Users,DC=example,DC=com']
            ]
        ];
        
        $this->ldapConnection->expects($this->once())
            ->method('search')
            ->willReturn($searchResult);
            
        $this->ldapConnection->expects($this->once())
            ->method('get_entries')
            ->with($searchResult)
            ->willReturn($entries);
        
        // Act
        $result = $this->service->syncEmployeeData($tabNumber);
        
        // Assert
        $this->assertTrue($result);
    }
    
    public function testGetAllEmployeesFromLdap(): void
    {
        // Arrange
        $searchResult = 'search_result';
        $entries = [
            'count' => 2,
            0 => [
                'employeenumber' => ['EMP001'],
                'cn' => ['John Doe'],
                'mail' => ['john.doe@example.com']
            ],
            1 => [
                'employeenumber' => ['EMP002'],
                'cn' => ['Jane Doe'],
                'mail' => ['jane.doe@example.com']
            ]
        ];
        
        $this->ldapConnection->expects($this->once())
            ->method('search')
            ->willReturn($searchResult);
            
        $this->ldapConnection->expects($this->once())
            ->method('get_entries')
            ->with($searchResult)
            ->willReturn($entries);
        
        // Act
        $result = $this->service->getAllEmployees();
        
        // Assert
        $this->assertIsArray($result);
        $this->assertCount(2, $result);
        $this->assertInstanceOf(LdapUserData::class, $result[0]);
        $this->assertInstanceOf(LdapUserData::class, $result[1]);
    }
    
    public function testIsConnectedReturnsTrueWhenConnected(): void
    {
        // Act
        $result = $this->service->isConnected();
        
        // Assert
        $this->assertTrue($result);
    }
} 