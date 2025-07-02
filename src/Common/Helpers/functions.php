<?php

declare(strict_types=1);

if (!function_exists('response')) {
    /**
     * Create a new response instance
     */
    function response($content = '', $status = 200, array $headers = [])
    {
        if (func_num_args() === 0) {
            return new class {
                public function json($data, $status = 200, array $headers = [], $options = 0)
                {
                    return new \Symfony\Component\HttpFoundation\JsonResponse($data, $status, $headers);
                }
            };
        }

        return new \Symfony\Component\HttpFoundation\Response($content, $status, $headers);
    }
} 