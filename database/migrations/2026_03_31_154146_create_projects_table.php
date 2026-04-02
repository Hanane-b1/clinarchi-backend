<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('projects', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('city');
            $table->integer('num_floors')->default(1);
            $table->integer('num_sous_sols')->default(0);
            $table->string('parking')->nullable();
            $table->decimal('terrain_surface', 15, 2)->nullable();
            $table->json('summary')->nullable();
            $table->json('filled_data')->nullable();
            $table->json('active_types')->nullable();
            $table->text('report')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('projects');
    }
};
