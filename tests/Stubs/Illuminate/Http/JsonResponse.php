<?php

namespace Illuminate\Http;

use Symfony\Component\HttpFoundation\JsonResponse as BaseJsonResponse;

class JsonResponse extends BaseJsonResponse
{
    // Наследуем от Symfony JsonResponse

    // Добавляем методы для совместимости с Laravel
    public function withCallback($callback = null)
    {
        if ($callback) {
            $this->setCallback($callback);
        }
        return $this;
    }
    
    public static function fromJsonString($data = null, $status = 200, $headers = [])
    {
        return new static($data, $status, $headers);
    }
} 