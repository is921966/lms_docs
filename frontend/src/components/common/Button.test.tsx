import { render, screen, fireEvent } from '@testing-library/react'
import { describe, it, expect, vi } from 'vitest'
import { Button } from './Button'

describe('Button', () => {
  it('renders with text', () => {
    render(<Button>Click me</Button>)
    expect(screen.getByText('Click me')).toBeInTheDocument()
  })

  it('handles click events', () => {
    const handleClick = vi.fn()
    render(<Button onClick={handleClick}>Click me</Button>)
    
    fireEvent.click(screen.getByText('Click me'))
    expect(handleClick).toHaveBeenCalledTimes(1)
  })

  it('can be disabled', () => {
    const handleClick = vi.fn()
    render(<Button disabled onClick={handleClick}>Click me</Button>)
    
    const button = screen.getByText('Click me')
    expect(button).toBeDisabled()
    
    fireEvent.click(button)
    expect(handleClick).not.toHaveBeenCalled()
  })

  it('applies variant styles', () => {
    const { rerender } = render(<Button variant="primary">Primary</Button>)
    expect(screen.getByText('Primary')).toHaveClass('bg-blue-600')
    
    rerender(<Button variant="secondary">Secondary</Button>)
    expect(screen.getByText('Secondary')).toHaveClass('bg-gray-600')
    
    rerender(<Button variant="danger">Danger</Button>)
    expect(screen.getByText('Danger')).toHaveClass('bg-red-600')
  })

  it('applies size styles', () => {
    const { rerender } = render(<Button size="small">Small</Button>)
    expect(screen.getByText('Small')).toHaveClass('text-sm')
    
    rerender(<Button size="medium">Medium</Button>)
    expect(screen.getByText('Medium')).toHaveClass('text-base')
    
    rerender(<Button size="large">Large</Button>)
    expect(screen.getByText('Large')).toHaveClass('text-lg')
  })

  it('shows loading state', () => {
    render(<Button loading>Loading</Button>)
    expect(screen.getByText('Loading...')).toBeInTheDocument()
    expect(screen.getByRole('button')).toBeDisabled()
  })
}) 