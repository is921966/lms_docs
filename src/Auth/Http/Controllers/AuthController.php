<?php

namespace Auth\Http\Controllers;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use Symfony\Component\Validator\Constraints as Assert;
use Auth\Application\Handlers\LoginHandler;
use Auth\Application\Handlers\RefreshTokenHandler;
use Auth\Application\Commands\LoginCommand;
use Auth\Application\Commands\RefreshTokenCommand;
use Auth\Domain\Repositories\TokenRepositoryInterface;
use Auth\Domain\Exceptions\AuthenticationException;
use Auth\Domain\Exceptions\InvalidTokenException;

class AuthController
{
    private ValidatorInterface $validator;
    private LoginHandler $loginHandler;
    private RefreshTokenHandler $refreshTokenHandler;
    private TokenRepositoryInterface $tokenRepository;

    public function __construct(
        ValidatorInterface $validator,
        LoginHandler $loginHandler,
        RefreshTokenHandler $refreshTokenHandler,
        TokenRepositoryInterface $tokenRepository
    ) {
        $this->validator = $validator;
        $this->loginHandler = $loginHandler;
        $this->refreshTokenHandler = $refreshTokenHandler;
        $this->tokenRepository = $tokenRepository;
    }

    public function login(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true);

        // Validate request
        $constraints = new Assert\Collection([
            'email' => [
                new Assert\NotBlank(['message' => 'Email is required']),
                new Assert\Email(['message' => 'Invalid email format'])
            ],
            'password' => [
                new Assert\NotBlank(['message' => 'Password is required']),
                new Assert\Length(['min' => 6, 'minMessage' => 'Password must be at least 6 characters'])
            ]
        ]);

        $violations = $this->validator->validate($data, $constraints);
        if (count($violations) > 0) {
            $errors = [];
            foreach ($violations as $violation) {
                $field = trim($violation->getPropertyPath(), '[]');
                $errors[$field][] = $violation->getMessage();
            }
            return new JsonResponse(['errors' => $errors], 422);
        }

        try {
            // Handle login
            $command = new LoginCommand($data['email'], $data['password']);
            $tokens = $this->loginHandler->handle($command);

            return new JsonResponse($tokens->toArray(), 200);

        } catch (AuthenticationException $e) {
            return new JsonResponse([
                'error' => 'Unauthorized',
                'message' => $e->getMessage()
            ], 401);
        }
    }

    public function refresh(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true);

        // Validate request
        if (empty($data['refresh_token'])) {
            return new JsonResponse([
                'errors' => ['refresh_token' => ['Refresh token is required']]
            ], 422);
        }

        try {
            // Handle refresh
            $command = new RefreshTokenCommand($data['refresh_token']);
            $tokens = $this->refreshTokenHandler->handle($command);

            return new JsonResponse($tokens->toArray(), 200);

        } catch (InvalidTokenException | AuthenticationException $e) {
            return new JsonResponse([
                'error' => 'Unauthorized',
                'message' => $e->getMessage()
            ], 401);
        } catch (\Exception $e) {
            return new JsonResponse([
                'error' => 'Server Error',
                'message' => 'An error occurred while refreshing token'
            ], 500);
        }
    }

    public function logout(Request $request): JsonResponse
    {
        // Get user ID from request (set by AuthenticationMiddleware)
        $userId = $request->attributes->get('userId');

        if ($userId) {
            // Revoke all user tokens
            $this->tokenRepository->revokeAllUserTokens($userId);
        }

        return new JsonResponse([
            'message' => 'Successfully logged out'
        ], 200);
    }

    public function me(Request $request): JsonResponse
    {
        // Get user info from request (set by AuthenticationMiddleware)
        $userId = $request->attributes->get('userId');
        $email = $request->attributes->get('userEmail');
        $roles = $request->attributes->get('userRoles');

        return new JsonResponse([
            'id' => $userId,
            'email' => $email,
            'roles' => $roles
        ], 200);
    }
} 