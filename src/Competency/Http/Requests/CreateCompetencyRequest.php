<?php

declare(strict_types=1);

namespace Competency\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class CreateCompetencyRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        // Check if user has permission to create competencies
        return $this->user() && $this->user()->can('competency.create');
    }

    /**
     * Get the validation rules that apply to the request.
     */
    public function rules(): array
    {
        return [
            'name' => [
                'required',
                'string',
                'min:3',
                'max:200',
                'unique:competencies,name'
            ],
            'description' => [
                'required',
                'string',
                'min:10',
                'max:1000'
            ],
            'category_id' => [
                'required',
                'string',
                'exists:competency_categories,id'
            ],
            'required_level' => [
                'nullable',
                'integer',
                'min:1',
                'max:5'
            ],
            'is_core' => [
                'nullable',
                'boolean'
            ]
        ];
    }

    /**
     * Get custom messages for validator errors.
     */
    public function messages(): array
    {
        return [
            'name.required' => 'Название компетенции обязательно',
            'name.min' => 'Название должно содержать минимум :min символа',
            'name.max' => 'Название не должно превышать :max символов',
            'name.unique' => 'Компетенция с таким названием уже существует',
            'description.required' => 'Описание компетенции обязательно',
            'description.min' => 'Описание должно содержать минимум :min символов',
            'description.max' => 'Описание не должно превышать :max символов',
            'category_id.required' => 'Категория компетенции обязательна',
            'category_id.exists' => 'Выбранная категория не существует',
            'required_level.min' => 'Уровень должен быть от :min до :max',
            'required_level.max' => 'Уровень должен быть от :min до :max'
        ];
    }

    /**
     * Prepare the data for validation.
     */
    protected function prepareForValidation(): void
    {
        // Trim whitespace from string fields
        $this->merge([
            'name' => trim($this->name ?? ''),
            'description' => trim($this->description ?? '')
        ]);
    }
}
