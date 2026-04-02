<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Project extends Model
{
    use HasFactory;

   protected $fillable = [
    'name', 'city', 'num_floors', 'num_sous_sols',
    'parking', 'terrain_surface', 'summary',
    'filled_data', 'active_types', 'report',
    'generated_date', 'generated_time',
    'total_beds', 'total_rooms', 'total_area_net', 'total_area_gross',
];
    protected $casts = [
        'summary' => 'array',
        'filled_data' => 'array',
        'active_types' => 'array',
        'terrain_surface' => 'float',
        'num_floors' => 'integer',
        'num_sous_sols' => 'integer',
    ];
}
