<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Api\ProjectController;

Route::get('/departments', function () {
    return response()->json(
        DB::table('departments')->get()
    );
});
Route::get('/php-check', function () {
    return response()->json([
        'php_version' => phpversion(),
        'pdo_pgsql_loaded' => extension_loaded('pdo_pgsql'),
        'pgsql_loaded' => extension_loaded('pgsql'),
        'loaded_ini' => php_ini_loaded_file(),
    ]);
});
Route::get('/debug-php', function () {
    return [
        'ini' => php_ini_loaded_file(),
        'extensions' => get_loaded_extensions(),
    ];
});

Route::get('/test', function () {
    return response()->json([
        "message" => "API marche 🔥"
    ]);
});

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

Route::apiResource('projects', ProjectController::class);
Route::post('/generate-report', function (Illuminate\Http\Request $request) {
    $response = \Illuminate\Support\Facades\Http::withHeaders([
        'x-api-key' => env('ANTHROPIC_API_KEY'),
        'anthropic-version' => '2023-06-01',
        'content-type' => 'application/json',
    ])->post('https://api.anthropic.com/v1/messages', $request->all());

    return response()->json($response->json());
    Route::post('/generate-report', function (Illuminate\Http\Request $request) {
    $response = \Illuminate\Support\Facades\Http::withHeaders([
        'x-api-key' => env('ANTHROPIC_API_KEY'),
        'anthropic-version' => '2023-06-01',
        'content-type' => 'application/json',
    ])->post('https://api.anthropic.com/v1/messages', $request->all());

    return response()->json($response->json());
});
Route::post('/generate-report', function (Illuminate\Http\Request $request) {
    $response = \Illuminate\Support\Facades\Http::withHeaders([
        'x-api-key' => env('ANTHROPIC_API_KEY'),
        'anthropic-version' => '2023-06-01',
        'content-type' => 'application/json',
    ])->post('https://api.anthropic.com/v1/messages', $request->all());

    return response()->json($response->json());
});
});