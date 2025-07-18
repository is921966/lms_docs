<?php

namespace Tests\Unit\ApiGateway\Http\Controllers;

use Tests\TestCase;
use App\ApiGateway\Http\Controllers\GatewayController;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class GatewayControllerTest extends TestCase
{
    private GatewayController $controller;

    protected function setUp(): void
    {
        parent::setUp();
        $this->controller = new GatewayController();
    }

    public function test_proxy_method_returns_json_response(): void
    {
        // Arrange
        $request = new Request();
        $service = 'user';
        $path = 'profile';

        // Act
        $response = $this->controller->proxy($request, $service, $path);

        // Assert
        $this->assertInstanceOf(JsonResponse::class, $response);
    }

    public function test_health_check_returns_success(): void
    {
        // Act
        $response = $this->controller->health();

        // Assert
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(200, $response->getStatusCode());
        $data = json_decode($response->getContent(), true);
        $this->assertEquals('ok', $data['status']);
    }
} 