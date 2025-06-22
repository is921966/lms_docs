<?php

namespace Tests\Unit\User\Domain\ValueObjects;

use Tests\TestCase;
use App\User\Domain\ValueObjects\UserId;

class UserIdTest extends TestCase
{
    /**
     * @test
     */
    public function it_generates_new_uuid(): void
    {
        $userId1 = UserId::generate();
        $userId2 = UserId::generate();
        
        $this->assertInstanceOf(UserId::class, $userId1);
        $this->assertInstanceOf(UserId::class, $userId2);
        
        // UUIDs should be unique
        $this->assertNotEquals($userId1->getValue(), $userId2->getValue());
        
        // Should be valid UUID v4
        $this->assertMatchesRegularExpression(
            '/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i',
            $userId1->getValue()
        );
    }
    
    /**
     * @test
     */
    public function it_creates_from_string(): void
    {
        $uuid = '550e8400-e29b-41d4-a716-446655440000';
        $userId = UserId::fromString($uuid);
        
        $this->assertInstanceOf(UserId::class, $userId);
        $this->assertEquals($uuid, $userId->getValue());
        $this->assertEquals($uuid, (string) $userId);
    }
    
    /**
     * @test
     */
    public function it_creates_from_legacy_id(): void
    {
        $legacyId = 12345;
        $userId = UserId::fromLegacyId($legacyId);
        
        $this->assertInstanceOf(UserId::class, $userId);
        // We can't get back the exact legacy ID, but we can check it's consistent
        $this->assertIsInt($userId->getLegacyId());
        
        // Should generate consistent UUID for same legacy ID
        $userId2 = UserId::fromLegacyId($legacyId);
        $this->assertEquals($userId->getValue(), $userId2->getValue());
    }
    
    /**
     * @test
     * @dataProvider invalidUuidProvider
     */
    public function it_throws_exception_for_invalid_uuid(string $invalidUuid): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid UUID format');
        
        UserId::fromString($invalidUuid);
    }
    
    /**
     * @test
     */
    public function it_compares_user_ids(): void
    {
        $uuid = '550e8400-e29b-41d4-a716-446655440000';
        $userId1 = UserId::fromString($uuid);
        $userId2 = UserId::fromString($uuid);
        $userId3 = UserId::generate();
        
        $this->assertTrue($userId1->equals($userId2));
        $this->assertFalse($userId1->equals($userId3));
    }
    
    /**
     * @test
     */
    public function it_checks_if_nil_uuid(): void
    {
        $nilUuid = '00000000-0000-0000-0000-000000000000';
        $normalUuid = '550e8400-e29b-41d4-a716-446655440000';
        
        $nilUserId = UserId::fromString($nilUuid);
        $normalUserId = UserId::fromString($normalUuid);
        
        $this->assertTrue($nilUserId->isNil());
        $this->assertFalse($normalUserId->isNil());
    }
    
    /**
     * @test
     */
    public function it_creates_nil_uuid(): void
    {
        $nilUserId = UserId::nil();
        
        $this->assertTrue($nilUserId->isNil());
        $this->assertEquals('00000000-0000-0000-0000-000000000000', $nilUserId->getValue());
    }
    
    /**
     * @test
     */
    public function it_serializes_to_json(): void
    {
        $uuid = '550e8400-e29b-41d4-a716-446655440000';
        $userId = UserId::fromString($uuid);
        
        $this->assertEquals('"' . $uuid . '"', json_encode($userId));
    }
    
    /**
     * @test
     */
    public function it_creates_from_bytes(): void
    {
        $userId = UserId::generate();
        $bytes = $userId->getBytes();
        
        $userIdFromBytes = UserId::fromBytes($bytes);
        
        $this->assertEquals($userId->getValue(), $userIdFromBytes->getValue());
    }
    
    /**
     * @test
     */
    public function it_validates_uuid_version(): void
    {
        // UUID v4
        $uuidV4 = '550e8400-e29b-41d4-a716-446655440000';
        $userIdV4 = UserId::fromString($uuidV4);
        $this->assertEquals(4, $userIdV4->getVersion());
        
        // UUID v1 is also accepted (we don't validate version)
        $uuidV1 = '550e8400-e29b-11d4-a716-446655440000';
        $userIdV1 = UserId::fromString($uuidV1);
        $this->assertEquals(1, $userIdV1->getVersion());
    }
    
    /**
     * @test
     */
    public function it_generates_deterministic_uuid_from_string(): void
    {
        $input = 'user@example.com';
        
        $userId1 = UserId::fromDeterministic($input);
        $userId2 = UserId::fromDeterministic($input);
        
        // Same input should generate same UUID
        $this->assertEquals($userId1->getValue(), $userId2->getValue());
        
        // Different input should generate different UUID
        $userId3 = UserId::fromDeterministic('other@example.com');
        $this->assertNotEquals($userId1->getValue(), $userId3->getValue());
    }
    
    public function invalidUuidProvider(): array
    {
        return [
            'empty string' => [''],
            'not a uuid' => ['not-a-uuid'],
            'too short' => ['550e8400-e29b-41d4-a716'],
            'too long' => ['550e8400-e29b-41d4-a716-446655440000-extra'],
            'invalid characters' => ['550e8400-e29b-41d4-a716-44665544000g'],
            'missing hyphens' => ['550e8400e29b41d4a716446655440000'],
            'wrong format' => ['550e8400e29b-41d4-a716-446655440000'],
        ];
    }
} 