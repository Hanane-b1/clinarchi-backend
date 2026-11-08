<?php

use App\Http\Controllers\Api\ProjectController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Route;

Route::get('/departments', function () {
    return response()->json(DB::table('departments')->get());
});

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

Route::apiResource('projects', ProjectController::class);

// Proxies report generation to the Claude API so the key stays on the server.
Route::post('/generate-report', function (Request $request) {
    $response = Http::withHeaders([
        'x-api-key' => env('ANTHROPIC_API_KEY'),
        'anthropic-version' => '2023-06-01',
        'content-type' => 'application/json',
    ])->post('https://api.anthropic.com/v1/messages', $request->all());

    return response()->json($response->json());
});
