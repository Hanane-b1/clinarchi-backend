<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up() {
        Schema::table('projects', function (Blueprint $table) {
            $table->jsonb('summary')->nullable();
            $table->jsonb('filled_data')->nullable();
            $table->jsonb('active_types')->nullable();
            $table->string('date')->nullable();
            $table->string('time')->nullable();
        });
    }

    public function down() {
        Schema::table('projects', function (Blueprint $table) {
            $table->dropColumn(['summary','filled_data','active_types','date','time']);
        });
    }
};