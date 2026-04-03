<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up()
    {
        Schema::table('projects', function (Blueprint $table) {
            if (!Schema::hasColumn('projects', 'summary')) {
                $table->jsonb('summary')->nullable();
            }
            if (!Schema::hasColumn('projects', 'filled_data')) {
                $table->jsonb('filled_data')->nullable();
            }
            if (!Schema::hasColumn('projects', 'active_types')) {
                $table->jsonb('active_types')->nullable();
            }
            if (!Schema::hasColumn('projects', 'date')) {
                $table->string('date', 255)->nullable();
            }
        });
    }

    public function down()
    {
        Schema::table('projects', function (Blueprint $table) {
            $table->dropColumn(['summary', 'filled_data', 'active_types', 'date']);
        });
    }
};
