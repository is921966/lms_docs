import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { VKLoginButton } from './VKLoginButton';
import '@testing-library/jest-dom';

// Mock VK SDK
const mockVKAuth = jest.fn();
global.VK = {
  Auth: {
    login: mockVKAuth
  },
  init: jest.fn()
};

describe('VKLoginButton', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should render login button with correct text', () => {
    render(<VKLoginButton />);
    
    const button = screen.getByRole('button', { name: /войти через vk id/i });
    expect(button).toBeInTheDocument();
  });

  it('should have VK brand styling', () => {
    render(<VKLoginButton />);
    
    const button = screen.getByRole('button', { name: /войти через vk id/i });
    expect(button).toHaveClass('bg-blue-600');
    expect(button).toHaveClass('hover:bg-blue-700');
  });

  it('should call VK Auth when clicked', async () => {
    const onSuccess = jest.fn();
    render(<VKLoginButton onSuccess={onSuccess} />);
    
    const button = screen.getByRole('button', { name: /войти через vk id/i });
    fireEvent.click(button);
    
    expect(mockVKAuth).toHaveBeenCalledWith(expect.any(Function), 262144); // 262144 = email permission
  });

  it('should show loading state while authenticating', async () => {
    render(<VKLoginButton />);
    
    const button = screen.getByRole('button', { name: /войти через vk id/i });
    fireEvent.click(button);
    
    expect(button).toBeDisabled();
    expect(screen.getByText(/входим/i)).toBeInTheDocument();
  });

  it('should call onSuccess callback when auth succeeds', async () => {
    const onSuccess = jest.fn();
    const mockSession = {
      user: {
        id: '123',
        first_name: 'Иван',
        last_name: 'Иванов',
        photo_100: 'https://vk.com/photo.jpg'
      },
      sid: 'test-session-id'
    };
    
    // Настраиваем mock для успешной авторизации
    mockVKAuth.mockImplementation((callback) => {
      callback(mockSession);
    });
    
    render(<VKLoginButton onSuccess={onSuccess} />);
    
    const button = screen.getByRole('button', { name: /войти через vk id/i });
    fireEvent.click(button);
    
    await waitFor(() => {
      expect(onSuccess).toHaveBeenCalledWith(mockSession);
    });
  });

  it('should show error message when auth fails', async () => {
    const onError = jest.fn();
    
    // Настраиваем mock для неудачной авторизации
    mockVKAuth.mockImplementation((callback) => {
      callback({ error: 'access_denied' });
    });
    
    render(<VKLoginButton onError={onError} />);
    
    const button = screen.getByRole('button', { name: /войти через vk id/i });
    fireEvent.click(button);
    
    await waitFor(() => {
      expect(onError).toHaveBeenCalled();
      expect(screen.getByText(/ошибка авторизации/i)).toBeInTheDocument();
    });
  });

  it('should be disabled when disabled prop is true', () => {
    render(<VKLoginButton disabled={true} />);
    
    const button = screen.getByRole('button', { name: /войти через vk id/i });
    expect(button).toBeDisabled();
  });

  it('should show custom loading text', () => {
    render(<VKLoginButton loadingText="Подождите..." />);
    
    const button = screen.getByRole('button', { name: /войти через vk id/i });
    fireEvent.click(button);
    
    expect(screen.getByText('Подождите...')).toBeInTheDocument();
  });
}); 